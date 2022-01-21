import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/home/new/newPost/newPoll.dart';
import 'package:hs_connect/services/groups_database.dart';
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

class PostForm extends StatefulWidget {
  final UserData userData;

  const PostForm({Key? key, required this.userData}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  File? newFile;
  Widget? poll;

  // form values
  String _title = '';
  String _text = '';
  String _tag = '';
  String error = '';
  bool loading = false;

  ImageStorage _images = ImageStorage();

  bool groupIsChecked = false;
  bool publicIsChecked = false;

  List<Group>? groupChoices;

  Group? selectedGroup;

  GroupsDatabaseService? _groups;

  @override
  void initState() {
    getGroupChoices();
    super.initState();
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
    double phoneHeight = MediaQuery.of(context).size.height - 200;

    final userData = Provider.of<UserData?>(context);
    if (userData == null || groupChoices == null || selectedGroup == null) {
      // Don't expect to be here, but just in case
      return Loading();
    }

    return Stack(children: [
      Positioned(
          bottom: 0,
          left: 0,
          child: Row(children: <Widget>[
            picPickerButton(
                iconSize: 25.0,
                color: ThemeColor.mediumGrey,
                setPic: ((File? f) {
                  if (mounted) {
                    setState(() {
                      newFile = f;
                    });
                  }
                })),
            SizedBox(width: 30),
            IconButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      poll = NewPoll();
                    });
                  }
                },
                icon: Icon(Icons.assessment,
                size: 25,
                color: ThemeColor.mediumGrey))
          ])),
      SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 50), //TODO: Find media height
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //Top ROW
                children: [
                  SizedBox(height: 50),
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
                            SizedBox(width: 5),
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
                        if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                          if (mounted) {
                            setState(() => loading = true);
                          }
                          String? downloadURL;
                          if (newFile != null) {
                            // upload newFile
                            downloadURL = await _images.uploadImage(file: newFile!);
                          }
                          await PostsDatabaseService(currUserRef: userData.userRef).newPost(
                            title: _title,
                            text: _text,
                            tagString: _tag,
                            media: downloadURL,
                            pollRef: null,
                            groupRef: selectedGroup!.groupRef,
                            onValue: handleValue,
                            onError: handleError,
                          );
                        }
                      }),
                ],
              ),
              SizedBox(height: 21),
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
              Container(
                //TextInput Container
                constraints: BoxConstraints(
                  maxHeight: double.infinity,
                  minHeight: phoneHeight,
                ),
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(
                        color: HexColor("223E52"),
                        fontSize: 22,
                      ),
                      maxLines: null,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: HexColor("223E52"),
                            fontSize: 22,
                            //fontWeight: ,
                          ),
                          border: InputBorder.none,
                          hintText: "What's up?"),
                      validator: (val) {
                        if (val == null) return 'Error: null value';
                        if (val.isEmpty)
                          return 'Can\'t create an empty post';
                        else
                          return null;
                      },
                      onChanged: (val) => setState(() => _title = val),
                    ),
                    TextFormField(
                      style: TextStyle(
                        color: HexColor("B5BABE"),
                        fontSize: 18,
                        //fontWeight: ,
                      ),
                      maxLines: null,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: HexColor("B5BABE"),
                            fontSize: 18,
                            //fontWeight: ,
                          ),
                          border: InputBorder.none,
                          hintText: "optional text"),
                      onChanged: (val) => setState(() => _text = val),
                    ),
                    SizedBox(height: 30),
                    poll != null ? poll! : Container()
                  ],
                ),
              ), //
            ],
          ),
        ),
      )
    ]);
  }
}
