import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/new/newPost/newPoll.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/polls_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/widgets/animatedSwitch.dart';
import 'package:hs_connect/shared/widgets/deletableImage.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/widgets/picPickerButton.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:validators/validators.dart';

import 'groupSelectionSheet.dart';

const String emptyPollChoiceError = 'Can\'t create a poll with an empty choice';
const String emptyTitleError = 'Can\'t create a post with an empty title';
const String badLinkError = 'Please enter a valid URL link';

class PostForm extends StatefulWidget {
  final UserData currUserData;

  const PostForm({Key? key, required this.currUserData}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  FocusNode optionalTextFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  void handleError(err) {
    if (mounted) {
      setState(() {
        error = 'ERROR: something went wrong while submitting post';
      });
    }
  }

  void handleValue(val) {
    Navigator.pop(context);
  }

  File? newFile;
  Widget? poll;
  String? link;
  List<String>? pollChoices;

  // form values
  String _title = '';
  String _text = '';
  String _tag = '';
  bool isMature = false;
  String? error;
  bool loading = false;

  ImageStorage _images = ImageStorage();
  PollsDatabaseService _polls = PollsDatabaseService();

  List<Group>? groupChoices;

  Group? selectedGroup;

  GroupsDatabaseService? _groups;

  @override
  void initState() {
    getGroupChoices();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    optionalTextFocusNode.dispose();
    super.dispose();
  }

  Future getGroupChoices() async {
    _groups = GroupsDatabaseService(currUserRef: widget.currUserData.userRef);
    final nullGroups = await _groups!.getGroups(groupsRefs: widget.currUserData.groups, withPublic: true);
    List<Group> groups = [];
    for (Group? group in nullGroups) {
      if (group != null) {
        if (group.accessRestriction.restrictionType == AccessRestrictionType.domain) {
          // replace domain group name with full domain name
          if (widget.currUserData.fullDomainName != null) {
            group.name = widget.currUserData.fullDomainName!;
          }
          // make this the default selected group
          if (mounted) {
            setState(() {
              selectedGroup = group;
            });
          }
        }
        groups.add(group);
      }
    }
    groups.sort((a, b) => a.name.compareTo(b.name));
    if (mounted) {
      setState(() {
        groupChoices = groups;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double phoneHeight = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    if (groupChoices == null || selectedGroup == null || loading) {
      return Loading();
    }

    Color userColor =
        widget.currUserData.domainColor != null ? widget.currUserData.domainColor! : colorScheme.onSurface;

    return Stack(children: [
      SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).padding.top),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //Top ROW
                children: [
                  SizedBox(width: 10),
                  TextButton(
                    child: Text("Cancel",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () => showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        )),
                        builder: (context) => GroupSelectionSheet(
                            initialSelectedGroup: selectedGroup!,
                            onSelectGroup: (Group? group) {
                              if (mounted) {
                                setState(() {
                                  selectedGroup = group;
                                });
                              }
                            },
                            groups: groupChoices!)),
                    child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(15, 6, 8, 6),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Text(selectedGroup!.name, style: Theme.of(context).textTheme.headline6),
                            Icon(Icons.keyboard_arrow_down_rounded),
                          ],
                        )),
                  ),
                  Spacer(),
                  GestureDetector(
                      onTap: () async {
                        // check header isn't empty
                        if (_title.isEmpty) {
                          if (mounted) {
                            setState(() {
                              error = emptyTitleError;
                            });
                          }
                          return;
                        }
                        // check link is good
                        if (link != null) {
                          if (!isURL(link!)) {
                            if (mounted) {
                              setState(() {
                                error = badLinkError;
                              });
                            }
                            return;
                          }
                        }
                        // check no empty poll choices
                        if (poll != null && pollChoices != null) {
                          for (String choice in pollChoices!) {
                            if (choice == "") {
                              if (mounted) {
                                setState(() {
                                  error = emptyPollChoiceError;
                                });
                              }
                              return;
                            }
                          }
                        }
                        if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                          // set to loading screen
                          if (mounted) {
                            setState(() => loading = true);
                          }
                          // handle image if applicable
                          String? downloadURL;
                          if (newFile != null) {
                            // upload newFile
                            downloadURL = await _images.uploadImage(file: newFile!);
                          }
                          // handle poll if applicable
                          DocumentReference? pollRef;
                          if (poll != null && pollChoices != null) {
                            pollRef = await _polls.newPoll(choices: pollChoices!);
                          }

                          await PostsDatabaseService(currUserRef: widget.currUserData.userRef).newPost(
                            title: _title,
                            text: _text,
                            tagString: _tag,
                            media: downloadURL,
                            pollRef: pollRef,
                            link: link,
                            groupRef: selectedGroup!.groupRef,
                            mature: isMature,
                            onValue: handleValue,
                            onError: handleError,
                          );
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: userColor, width: 2),
                            borderRadius: BorderRadius.circular(25),
                            color: _title != '' ? userColor : colorScheme.surface,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 1.5, horizontal: 6),
                          child: Row(
                            children: [
                              Icon(Icons.add, size: 20, color: _title != '' ? colorScheme.surface : userColor),
                              SizedBox(width: 2),
                              FittedBox(
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 1, top: 1, right: 5),
                                  child: Text("Post",
                                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: _title != '' ? colorScheme.surface : userColor),
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade),
                                ),
                              ),
                            ],
                          ))),
                  SizedBox(width: 10),
                ],
              ),
              Divider(height: 4, indent: 0, thickness: 2, color: Theme.of(context).colorScheme.onError),
              Container(
                //TextInput Container
                constraints: BoxConstraints(
                  minHeight: phoneHeight * 0.75,
                ),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(children: <Widget>[
                  error != null
                      ? FittedBox(
                          child: Text(error!,
                              style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.onSurface)))
                      : Container(),
                  error != null ? SizedBox(height: 10) : Container(),
                  TextFormField(
                    style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
                    maxLines: null,
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(fontSize: 18, color: colorScheme.primaryContainer),
                      border: InputBorder.none,
                      hintText: "Title",
                    ),
                    onChanged: (val) {
                      setState(() => _title = val);
                      if (error == emptyTitleError) {
                        if (mounted) {
                          setState(() {
                            error = null;
                          });
                        }
                      }
                    },
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (!optionalTextFocusNode.hasFocus) {
                        optionalTextFocusNode.requestFocus();
                      }
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: newFile == null ? 492 : 100,
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 16),
                            maxLines: null,
                            autocorrect: true,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(fontSize: 16, color: colorScheme.primary),
                                border: InputBorder.none,
                                hintText: "Optional text"),
                            onChanged: (val) => setState(() => _text = val),
                            focusNode: optionalTextFocusNode,
                          ),
                          poll != null ? poll! : Container(),
                          link != null
                              ? Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: BorderSide(
                                        color: colorScheme.onError,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: TextFormField(
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 16),
                                    decoration: new InputDecoration(
                                        fillColor: colorScheme.surface,
                                        filled: true,
                                        hintText: 'https://website.com',
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            ?.copyWith(fontSize: 16, color: colorScheme.primary),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                        suffixIcon: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          onPressed: () {
                                            if (mounted) {
                                              setState(() => link = null);
                                            }
                                          },
                                          icon: Icon(Icons.close, size: 20),
                                        )),
                                    autocorrect: false,
                                    onChanged: (val) {
                                      setState(() => link = val);
                                      if (error == badLinkError) {
                                        if (mounted) {
                                          setState(() {
                                            error = null;
                                          });
                                        }
                                      }
                                    },
                                    textAlignVertical: TextAlignVertical.center,
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                  newFile != null
                      ? Semantics(
                          label: 'new_post_pic_image',
                          child: DeletableImage(
                              image: Image.file(File(newFile!.path), fit: BoxFit.contain),
                              onDelete: () {
                                if (mounted) {
                                  setState(() => newFile = null);
                                }
                              },
                              maxHeight: 350,
                              containerWidth: 350),
                        )
                      : Container(),
                ]),
              ), //
            ],
          ),
        ),
      ),
      Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            color: widget.currUserData.domainColor != null ? widget.currUserData.domainColor! : colorScheme.onSurface,
            padding: EdgeInsets.only(top: bottomGradientThickness),
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: colorScheme.surface,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: Row(children: <Widget>[
                SizedBox(width: 10),
                picPickerButton(
                    iconSize: 30,
                    color: newFile == null ? colorScheme.primary : userColor,
                    setPic: ((File? f) {
                      if (mounted) {
                        setState(() {
                          newFile = f;
                          poll = null;
                          link = null;
                        });
                      }
                    }),
                    context: context,
                    maxHeight: 1200,
                    maxWidth: 1200),
                SizedBox(width: 2),
                IconButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        pollChoices = [];
                        pollChoices!.add('');
                        pollChoices!.add('');
                        poll = NewPoll(onDeletePoll: () {
                          if (mounted) {
                            setState(() {
                              poll = null;
                              pollChoices = null;
                              if (error == emptyPollChoiceError) {
                                error = null;
                              }
                            });
                          }
                        }, onUpdatePoll: (int index, String newChoice) {
                          if (mounted) {
                            setState(() {
                              pollChoices![index] = newChoice;
                              if (error == emptyPollChoiceError) {
                                for (String choice in pollChoices!) {
                                  if (choice == '') return;
                                }
                              }
                              error = null;
                            });
                          }
                        }, onAddPollChoice: () {
                          if (mounted) {
                            setState(() {
                              pollChoices!.add('');
                            });
                          }
                        });
                        newFile = null;
                        link = null;
                      });
                    }
                  },
                  icon: Icon(Icons.assessment, size: 30, color: poll == null ? colorScheme.primary : userColor),
                ),
                IconButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        link = '';
                        newFile = null;
                        poll = null;
                      });
                    }
                  },
                  icon: Icon(Icons.link_rounded, size: 30, color: link == null ? colorScheme.primary : userColor),
                ),
                Spacer(),
                Text("Mature",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w500)),
                SizedBox(width: 10),
                AnimatedSwitchSmall(
                  initialState: isMature,
                  onToggle: () {
                    if (mounted) {
                      setState(() => isMature = !isMature);
                    }
                  },
                ),
                SizedBox(width: 10),
              ]),
            ),
          )),
    ]);
  }
}
