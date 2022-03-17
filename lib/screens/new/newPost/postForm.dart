import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
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
import 'package:hs_connect/shared/widgets/myLinkPreview.dart';
import 'package:hs_connect/shared/widgets/picPickerButton.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

import '../../../shared/widgets/myDivider.dart';
import 'groupSelectionSheet.dart';

const String emptyPollChoiceError = 'Can\'t create a poll with an empty choice';
const String emptyTitleError = 'Can\'t create a post with an empty title';
const String badLinkError = 'Please enter a valid URL link';
const String spamPostError = 'Please wait 1 minute between posts';

class PostForm extends StatefulWidget {
  final UserData currUserData;

  const PostForm({Key? key, required this.currUserData}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  FocusNode titleFocusNode = FocusNode();

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
  PreviewData? previewData;
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
    titleFocusNode.dispose();
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
    final textTheme = Theme.of(context).textTheme;

    if (groupChoices == null || selectedGroup == null || loading) {
      return Loading();
    }

    Color userColor = widget.currUserData.domainColor ?? colorScheme.onSurface;

    return Stack(children: [
      SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).padding.top),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //Top ROW
              children: [
                SizedBox(width: 12),
                TextButton(
                  child: Text("Cancel",
                      style: textTheme.subtitle1?.copyWith(color: colorScheme.onSurface)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 12),
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
                          Text(selectedGroup!.name, style: textTheme.headline6),
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
                      final lastPostCheck = Provider.of<UserData?>(context, listen: false);
                      if (lastPostCheck != null &&
                          lastPostCheck.lastPostTime != null &&
                          lastPostCheck.lastPostTime!
                                  .toDate()
                                  .compareTo(DateTime.now().subtract(Duration(minutes: 1))) >
                              0) {
                        if (mounted) {
                          setState(() {
                            error = spamPostError;
                          });
                        }
                        return;
                      }
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
                                child: Text("Send",
                                    style: textTheme.subtitle1?.copyWith(
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
            MyDivider(),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (!titleFocusNode.hasFocus) {
                  titleFocusNode.requestFocus();
                }
              },
              child: Container(
                constraints: BoxConstraints(
                  minHeight: phoneHeight * 0.75,
                ),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(children: <Widget>[
                  error != null
                      ? FittedBox(
                          child: Text(error!, style: textTheme.subtitle2?.copyWith(color: colorScheme.onSurface)))
                      : Container(),
                  error != null ? SizedBox(height: 10) : Container(),
                  TextFormField(
                    autofocus: true,
                    style: Theme.of(context).textTheme.headline5,
                    maxLines: null,
                    autocorrect: true,
                    focusNode: titleFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintStyle: textTheme.headline5?.copyWith(color: colorScheme.primary),
                      border: InputBorder.none,
                      hintText: "What's up?",
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
                  SizedBox(height: 10),
                  poll != null ? poll! : Container(),
                  link != null
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: colorScheme.onError,
                                width: 1,
                              ),
                            ),
                          ),
                          child: TextFormField(
                            style: textTheme.bodyText2?.copyWith(fontSize: 16),
                            decoration: InputDecoration(
                                fillColor: Colors.transparent,
                                filled: true,
                                hintText: 'https://website.com',
                                isCollapsed: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintStyle: textTheme.bodyText2?.copyWith(fontSize: 16, color: colorScheme.primary),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                suffixIcon: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed: () {
                                    if (mounted) {
                                      setState(() {
                                        link = null;
                                        previewData = null;
                                      });
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
                      : Container(),
                  link != null && isURL(link) ? Container(
                    padding: EdgeInsets.only(top: 10),
                    child: MyLinkPreview(
                        enableAnimation: true,
                        onPreviewDataFetched: (data) {
                          if (mounted) {
                            setState(() => previewData = data);
                          }
                        },
                        metadataTitleStyle: textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold),
                        metadataTextStyle: textTheme.subtitle1?.copyWith(fontSize: 14),
                        previewData: previewData,
                        text: link!,
                        textStyle: textTheme.subtitle2,
                        linkStyle: textTheme.subtitle2,
                        width: MediaQuery.of(context).size.width - 40),
                  ) : Container(),
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
              ),
            ), //
          ],
        ),
      ),
      Positioned(
          bottom: 0,
          left: 0,
          child: Column(
            children: [
              Container(width: MediaQuery.of(context).size.width, child: MyDivider()),
              Container(
                width: MediaQuery.of(context).size.width,
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
                            previewData = null;
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
                          previewData = null;
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
                          previewData = null;
                          newFile = null;
                          poll = null;
                        });
                      }
                    },
                    icon: Icon(Icons.link_rounded, size: 30, color: link == null ? colorScheme.primary : userColor),
                  ),
                  Spacer(),
                  Text("Mature",
                      style: textTheme.subtitle1?.copyWith(color: colorScheme.primary)),
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
            ],
          )),
    ]);
  }
}
