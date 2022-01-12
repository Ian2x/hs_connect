import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/noAnimationMaterialPageRoute.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/widgets/picPickerButton.dart';
import 'package:hs_connect/shared/widgets/tagOutline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';

import 'imagePreview.dart';

class PostForm extends StatefulWidget {
  const PostForm({Key? key}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();

  void handleError(err) {
    setState(() {
      error = 'ERROR: something went wrong, possibly with username to email conversion';
    });
  }

  void handleValue(val) {
    loading = false;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  String? newFileURL;
  File? newFile;

  bool isPost=true;

  // form values
  String _title = '';
  String _text = '';
  DocumentReference? _groupRef = null;
  String _tag = '';
  String error = '';
  bool loading = false;
  bool hasPic=false;

  String _groupName = '';
  String _description = '';
  AccessRestriction? _accessRestriction = null;

  ImageStorage _images = ImageStorage();


  @override
  Widget build(BuildContext context) {


    double phoneHeight = MediaQuery.of(context).size.height - 200;

    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    }

    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: userData.userRef);

    final List<AccessRestriction> accessOptions = [
      AccessRestriction(restrictionType: AccessRestrictionType.domain, restriction: userData.domain),
    ];
    if (userData.county != null) {
      accessOptions
          .add(AccessRestriction(restrictionType: AccessRestrictionType.county, restriction: userData.county!));
    }
    if (userData.state != null) {
      accessOptions.add(AccessRestriction(restrictionType: AccessRestrictionType.state, restriction: userData.state!));
    }
    if (userData.country != null) {
      accessOptions
          .add(AccessRestriction(restrictionType: AccessRestrictionType.country, restriction: userData.country!));
    }

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    }

    void submitForm() async {
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        setState(() => loading = true);
        await PostsDatabaseService(currUserRef: userData.userRef).newPost(
          title: _title,
          text: _text,
          tagString: _tag,
          media: newFileURL,
          pollRef: null, //until poll is implemented
          groupRef: _groupRef!,
          onValue: handleValue,
          onError: handleError,
        );
      }
      if (newFile != null) {
        // upload newFile
        final downloadURL = await _images.uploadImage(file: newFile!);
        setState(() {
          newFileURL = downloadURL;
        });
      }
    }

    void setPic(File x) {
      setState(() {
        newFile = x;
      });
    }

    return FutureBuilder(
        future: _groups.getUserGroups(userGroups: userData.userGroups),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final nullGroups = snapshot.data as List<Group?>;
            List<Group> groups = [];
            for (Group? group in nullGroups) {
              if (group!=null) {
                groups.add(group);
              }
            }
            if (isPost){
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height:30), //TODO: Find media height
                      Row(
                        children: [
                          IconButton( icon:Icon(Icons.arrow_back_ios_rounded, size:23.0),
                            onPressed:() {
                              Navigator.pushReplacement(
                                context, NoAnimationMaterialPageRoute(builder: (context) => Home()),);
                            },
                          ),
                          Spacer(flex:6),
                          tagOutline(
                            textOnly:true,
                            text: "Post",
                            textColor: "54A0DC",
                            borderColor: "54A0DC",
                          ),
                          Spacer(flex:1),
                          TextButton (
                            onPressed:(){
                              setState((){
                                isPost=false;
                              });
                            },
                            child: Text("Group",
                              style: TextStyle(
                                color: ThemeColor.hintTextGrey,
                                fontSize:16,
                              ),
                            ),
                          ),
                          Spacer(flex:6),
                          IconButton(onPressed: submitForm,
                              icon: Icon(Icons.add_circle_rounded, color: ThemeColor.secondaryBlue, size: 30.0)),
                        ],
                      ),
                      SizedBox(height:15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            flex:4,
                            child: Container(
                              height: 64,
                              width:double.infinity,
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
                              decoration: ShapeDecoration(
                                color: HexColor('FFFFFF'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(ThemeLayout.borderRadius),
                                    side: BorderSide(
                                      color: ThemeColor.lightGrey,
                                      width: 3.0,
                                    )),
                              ),
                              child: DropdownButtonFormField<DocumentReference>(
                                  iconSize:0.0,
                                  itemHeight: 48.0,
                                  isExpanded: true,
                                  decoration: textInputDecoration,
                                  hint: Text(
                                    "Add a group",
                                    style: TextStyle(
                                      color: ThemeColor.hintTextGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  value: _groupRef != null ? _groupRef : null,
                                  items: groups.map((group) {
                                    return DropdownMenuItem(
                                      value: group.groupRef,
                                      child: Text(
                                        group.name,
                                        style: TextStyle(
                                          color: HexColor("B5BABE"),
                                          fontSize: 14,
                                          //fontWeight: ,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _groupRef = val!),
                                  validator: (val) {
                                    if (val == null)
                                      return 'Pick a group to post to';
                                    else
                                      return null;
                                  }),
                            ),
                          ),
                          SizedBox(width:15),
                          Flexible(
                            flex:1,
                            child: Container(
                              height: 64,
                              width: 64,
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
                              decoration: ShapeDecoration(
                                color: HexColor("FFFFFF"),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(ThemeLayout.borderRadius),
                                    side: BorderSide(
                                      color: ThemeColor.lightGrey,
                                      width: 3.0,
                                    )),
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  try {
                                    final pickedFile = await ImagePicker().pickImage(
                                      source: ImageSource.gallery,
                                      maxHeight:400,
                                      maxWidth:400,
                                      imageQuality: 100,
                                    );
                                    if (pickedFile != null) {
                                      if (mounted) {
                                        setState(() {
                                          newFile = File(pickedFile.path);
                                        });
                                      }
                                    } else {
                                      if (mounted) {
                                        setState(() {
                                          newFile = null;
                                        });
                                      }
                                    }
                                    setState(() {
                                      if (newFile!=null) {
                                        hasPic=true;
                                      }
                                    });
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                icon: Icon(Icons.photo, color:ThemeColor.secondaryBlue,size:30),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height:15),
                      hasPic!= false ? SizedBox(height:10): SizedBox(),
                      hasPic!= false ? imagePreview(fileImage: newFile) : SizedBox(),
                      hasPic!= false ? SizedBox(height:10) : SizedBox(),
                      Container(
                        //TextInput Container
                        constraints: BoxConstraints(
                          maxHeight: double.infinity,
                          minHeight: phoneHeight,
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        decoration: ShapeDecoration(
                          color: HexColor('FFFFFF'),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ThemeLayout.borderRadius),
                              side: BorderSide(
                                color: HexColor("E9EDF0"),
                                width: 3.0,
                              )),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              style: TextStyle(
                                color: HexColor("223E52"),
                                fontSize: 22,
                                //fontWeight: ,
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
                            )
                          ],
                        ),
                      ), //
                    ],
                  ),
                ),
              );
            } else {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height:30), //TODO: Find media height
                      Row(
                        children: [
                          IconButton( icon:Icon(Icons.arrow_back_ios_rounded, size: 23.0),
                            onPressed:() {
                              Navigator.pushReplacement(
                                context, NoAnimationMaterialPageRoute(builder: (context) => Home()),);
                            },
                          ),
                          Spacer(flex:6),
                          TextButton (
                            onPressed:(){
                              setState((){
                                isPost=true;
                              });
                            },
                            child: Text("Post",
                              style: TextStyle(
                                color: ThemeColor.hintTextGrey,
                                fontSize: ThemeText.regular,
                              ),
                            ),
                          ),
                          Spacer(flex:1),
                          tagOutline(
                            textOnly:true,
                            text: "Group",
                            textColor: "54A0DC",
                            borderColor: "54A0DC",
                          ),
                          Spacer(flex:6),
                          IconButton(onPressed: () async {
                            if (newFile != null) {
                              // upload newFile
                              final downloadURL = await _images.uploadImage(file: newFile!);
                              if (mounted) {
                                setState(() {
                                  newFileURL = downloadURL;
                                });
                              }
                            }

                            if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                              if (mounted) {
                                setState(() => loading = true);
                              }
                              await _groups.newGroup(
                                accessRestriction: _accessRestriction!,
                                name: _groupName,
                                creatorRef: userData.userRef,
                                image: newFileURL,
                                description: _description,
                                onValue: handleValue,
                                onError: handleError,
                              );
                            }
                          },
                              icon: Icon(Icons.add_circle_rounded, color: ThemeColor.secondaryBlue, size:30.0)),
                        ],
                      ), //Top Row
                      SizedBox(height:15),
                      Row(   //GroupTitle Row
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 4,
                            child: Container(
                              height: 64,
                              //width: (MediaQuery.of(context).size.width) * .75,
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
                              decoration: ShapeDecoration(
                                color: HexColor('FFFFFF'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(ThemeLayout.borderRadius),
                                    side: BorderSide(
                                      color: ThemeColor.lightGrey,
                                      width: 3.0,
                                    )),
                              ),
                              child:
                              DropdownButtonFormField<AccessRestriction>(
                                iconSize:0.0,
                                hint: Text(
                                  "Who can see this group?",
                                  style: TextStyle(
                                    color: ThemeColor.hintTextGrey,
                                    fontSize: 16,
                                  ),
                                ),
                                decoration: textInputDecoration,
                                value: _accessRestriction,
                                items: accessOptions.map((option) {
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(option.restriction),
                                  );
                                }).toList(),
                                validator: (value) => value == null ? 'Pick who can see this group' : null,
                                onChanged: (val) {
                                  if (mounted) {
                                    setState(() => _accessRestriction = val!);
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(width:15),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: 64,
                              width: (MediaQuery.of(context).size.width) * .75,
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
                              decoration: ShapeDecoration(
                                color: HexColor('FFFFFF'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(ThemeLayout.borderRadius),
                                    side: BorderSide(
                                      color: ThemeColor.secondaryBlue,
                                      width: 3.0,
                                    )),
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  try {
                                    final pickedFile = await ImagePicker().pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    if (pickedFile != null) {
                                      if (mounted) {
                                        setState(() {
                                          newFile = File(pickedFile.path);
                                        });
                                      }
                                    } else {
                                      if (mounted) {
                                        setState(() {
                                          newFile = null;
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                icon: Icon(Icons.photo, color:ThemeColor.secondaryBlue,size:30),
                              ),
                            ),
                          )
                        ],
                      ), //Title + Image Row
                    SizedBox(height:15),
                    Container(
                      //TextInput Container
                      //height: 100,
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      decoration: ShapeDecoration(
                        color: HexColor('FFFFFF'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ThemeLayout.borderRadius),
                            side: BorderSide(
                              color: HexColor("E9EDF0"),
                              width: 3.0,
                            )),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            style: TextStyle(
                              color: HexColor("223E52"),
                              fontSize: 22,
                              //fontWeight: ,
                            ),
                            maxLines: null,
                            decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  color: HexColor("223E52"),
                                  fontSize: 20,
                                  //fontWeight: ,
                                ),
                                border: InputBorder.none,
                                hintText: "Your Group's name?"),
                            validator: (val) {
                              if (val == null) return 'Error: null value';
                              if (val.isEmpty)
                                return 'Group name is required';
                              else
                                return null;
                            },
                            onChanged: (val) {
                              if (mounted) {
                                setState(() => _groupName = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height:15),
                    Container(
                        //TextInput Container
                        constraints: BoxConstraints(
                          maxHeight: double.infinity,
                          minHeight: phoneHeight,
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        decoration: ShapeDecoration(
                          color: HexColor('FFFFFF'),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ThemeLayout.borderRadius),
                              side: BorderSide(
                                color: HexColor("E9EDF0"),
                                width: 3.0,
                              )),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              style: TextStyle(
                                color: ThemeColor.hintTextGrey,
                                fontSize: ThemeText.regular,
                                //fontWeight: ,
                              ),
                              maxLines: null,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    color: ThemeColor.hintTextGrey,
                                    fontSize: ThemeText.regular,
                                    //fontWeight: ,
                                  ),
                                  border: InputBorder.none,
                                  hintText: "A group about..."),
                              validator: (val) {
                                if (val == null) return 'Describe your group';
                                if (val.isEmpty)
                                  return 'Can\'t create an empty group';
                                else
                                  return null;
                              },
                              onChanged: (val) => setState(() => _description = val),
                            ),
                          ],
                        ),
                      ), //Group Description
                    ],
                  ),
                ),
              );
            }
          } else {
            return Loading();
          }
        });
  }
}
