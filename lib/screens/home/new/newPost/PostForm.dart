import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/new/newPost/newPoll.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/polls_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/deletableImage.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/widgets/picPickerButton.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';

import 'modalBottomSheet.dart';

const String emptyPollChoiceError = 'Can\'t create a poll with an empty choice';
const String emptyTitleError = 'Can\'t create a post with an empty title';

class PostForm extends StatefulWidget {
  final UserData userData;

  const PostForm({Key? key, required this.userData}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

  void handleError(err) {
    if (mounted) {
      setState(() {
        error = 'ERROR: something went wrong while submitting post';
      });
    }
  }

  void handleValue(val) {
    loading = false;
    Navigator.pop(context);
  }

  File? newFile;
  Widget? poll;
  List<String>? pollChoices;

  // form values
  String _title = '';
  String _text = '';
  String _tag = '';
  String? error;
  bool loading = false;

  ImageStorage _images = ImageStorage();
  PollsDatabaseService _polls = PollsDatabaseService();

  bool groupIsChecked = false;
  bool publicIsChecked = false;

  List<Group>? groupChoices;

  Group? selectedGroup;

  GroupsDatabaseService? _groups;

  @override
  void initState() {
    getGroupChoices();
    myFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }

  Future getGroupChoices() async {
    _groups = GroupsDatabaseService(currUserRef: widget.userData.userRef);
    final nullGroups = await _groups!.getGroups(groupsRefs: widget.userData.groups, withPublic: true);
    List<Group> groups = [];
    for (Group? group in nullGroups) {
      if (group != null) {
        if (group.accessRestriction.restrictionType == AccessRestrictionType.domain) {
          // replace domain group name with full domain name
          if (widget.userData.fullDomainName != null) {
            group.name = widget.userData.fullDomainName!;
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
    double phoneWidth = MediaQuery.of(context).size.height;

    final userData = Provider.of<UserData?>(context);
    if (userData == null || groupChoices == null || selectedGroup == null || loading) {
      // Don't expect to be here, but just in case
      return Loading();
    }

    return Stack(children: [
      SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: phoneHeight * 0.07),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //Top ROW
                children: [
                  TextButton(
                    child: Text("Cancel", style: ThemeText.regularSmall(color: ThemeColor.mediumGrey, fontSize: 16)),
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
                        builder: (context) => new ModalBottomSheet(
                              initialSelectedGroup: selectedGroup!,
                              onSelectGroup: (Group? group) {
                                if (mounted) {
                                  setState(() {
                                    selectedGroup = group;
                                  });
                                }
                              },
                              groups: groupChoices!,
                            )),
                    child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
                        decoration: ShapeDecoration(
                          color: ThemeColor.lightGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedGroup!.name,
                              style: ThemeText.regularSmall(
                                fontSize: 18,
                                color: ThemeColor.black,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded),
                          ],
                        )),
                  ),
                  Spacer(),
                  TextButton(
                      child: Text(
                        "Post",
                        style: ThemeText.regularSmall(color: ThemeColor.secondaryBlue, fontSize: 16),
                      ),
                      onPressed: () async {
                        // check header isn't empty
                        if (_title.isEmpty) {
                          if (mounted) {
                            setState(() {
                              error = emptyTitleError;
                            });
                          }
                          return;
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

                          await PostsDatabaseService(currUserRef: userData.userRef).newPost(
                            title: _title,
                            text: _text,
                            tagString: _tag,
                            media: downloadURL,
                            pollRef: pollRef,
                            groupRef: selectedGroup!.groupRef,
                            onValue: handleValue,
                            onError: handleError,
                          );
                        }
                      }),
                ],
              ),
              Container(
                //TextInput Container
                constraints: BoxConstraints(
                  maxHeight: double.infinity,
                  minHeight: phoneHeight * 0.75,
                ),
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                child: Column(children: <Widget>[
                  SizedBox(height: phoneHeight * 0.02),
                  error != null
                      ? Text(error!, style: ThemeText.inter(fontSize: 14, color: Colors.red.shade700))
                      : Container(),
                  newFile != null
                      ? Semantics(
                          label: 'new_profile_pic_image',
                          child: DeletableImage(
                              image: Image.file(File(newFile!.path)),
                              onDelete: () {
                                if (mounted) {
                                  setState(() => newFile = null);
                                }
                              }),
                        )
                      : Container(),
                  TextFormField(
                    style: TextStyle(
                      color: HexColor("223E52"),
                      fontSize: 22,
                    ),
                    maxLines: null,
                    autocorrect: false,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(
                          color: HexColor("223E52"),
                          fontSize: 22,
                          //fontWeight: ,
                        ),
                        border: InputBorder.none,
                        hintText: "What's up?"),
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
                      myFocusNode.requestFocus();
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: double.infinity,
                        minHeight: newFile == null ? phoneHeight * 0.63 : phoneHeight * 0.31,
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            style: TextStyle(
                              color: HexColor("B5BABE"),
                              fontSize: 18,
                              //fontWeight: ,
                            ),
                            maxLines: null,
                            autocorrect: false,
                            decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  color: HexColor("B5BABE"),
                                  fontSize: 18,
                                  //fontWeight: ,
                                ),
                                border: InputBorder.none,
                                hintText: "optional text"),
                            onChanged: (val) => setState(() => _text = val),
                            focusNode: myFocusNode,
                          ),
                          SizedBox(height: 30),
                          poll != null ? poll! : Container(),
                        ],
                      ),
                    ),
                  ),
                ]),
              ), //
            ],
          ),
        ),
      ),
      Positioned(
          bottom: 0,
          left: 0,
          child: Row(children: <Widget>[
            picPickerButton(
                iconSize: 30.0,
                color: newFile == null ? ThemeColor.mediumGrey : ThemeColor.secondaryBlue,
                setPic: ((File? f) {
                  if (mounted) {
                    setState(() {
                      newFile = f;
                      poll = null;
                    });
                  }
                })),
            SizedBox(width: phoneWidth * 0.005),
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
                    });
                  }
                },
                icon: Icon(Icons.assessment,
                    size: 30, color: poll == null ? ThemeColor.mediumGrey : ThemeColor.secondaryBlue))
          ])),
    ]);
  }
}
