import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:hs_connect/shared/widgets/tagOutline.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';

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

  ImageStorage _images = ImageStorage();

  @override
  Widget build(BuildContext context) {
    double phoneHeight = MediaQuery.of(context).size.height - 200;

    final userData = Provider.of<UserData?>(context);

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

    final _GroupsDatabaseService = GroupsDatabaseService(currUserRef: userData.userRef);

    return FutureBuilder(
        future: _GroupsDatabaseService.getGroups(userGroups: userData.userGroups),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final groups = snapshot.data as List<Group>;
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
                                color: themeColor.textGrey,
                                fontSize:16,
                              ),
                            ),
                          ),
                          Spacer(flex:6),
                          IconButton(onPressed: submitForm,
                              icon: Icon(Icons.add_circle_rounded, color: themeColor.secBlue, size: 30.0)),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Container(
                              height: 64,
                              //width: (MediaQuery.of(context).size.width) * .75,
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
                              decoration: ShapeDecoration(
                                color: HexColor('FFFFFF'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(themeLayout.borderRadius),
                                    side: BorderSide(
                                      color: themeColor.neutralGrey,
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
                                      color: themeColor.textGrey,
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
                          SizedBox(width: 12),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: 64,
                              width: (MediaQuery.of(context).size.width) * .75,
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
                              decoration: ShapeDecoration(
                                color: HexColor('FFFFFF'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(themeLayout.borderRadius),
                                    side: BorderSide(
                                      color: HexColor("E9EDF0"),
                                      width: 3.0,
                                    )),
                              ),
                              child: DropdownButtonFormField<String>(
                                iconSize:0.0,
                                isExpanded: true,
                                decoration: textInputDecoration,
                                hint: Text(
                                  "+ Tag",
                                  style: TextStyle(
                                    color: themeColor.secBlue,
                                    fontSize: 16,
                                  ),
                                ),
                                value: _tag.isNotEmpty ? _tag : null,
                                items: Tag.values.map((tag) {
                                  return DropdownMenuItem(
                                    value: tag.string,
                                    child: Text(
                                      tag.string,
                                      style: TextStyle(
                                        color: HexColor("B5BABE"),
                                        fontSize: 14,
                                        //fontWeight: ,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _tag = val!),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 12),
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
                              borderRadius: BorderRadius.circular(themeLayout.borderRadius),
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
                              validator: (val) {
                                if (val == null) return 'Error: null value';
                                if (val.isEmpty)
                                  return 'Can\'t create an empty post';
                                else
                                  return null;
                              },
                              onChanged: (val) => setState(() => _title = val),
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
                                color: themeColor.textGrey,
                                fontSize: themeText.regular,
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
                          IconButton(onPressed: submitForm,
                              icon: Icon(Icons.add_circle_rounded, color: themeColor.secBlue, size:30.0)),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Container(
                              height: 64,
                              //width: (MediaQuery.of(context).size.width) * .75,
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
                              decoration: ShapeDecoration(
                                color: HexColor('FFFFFF'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(themeLayout.borderRadius),
                                    side: BorderSide(
                                      color: themeColor.neutralGrey,
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
                                      color: themeColor.textGrey,
                                      fontSize: themeText.regular,
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
                          SizedBox(width: 12),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: 64,
                              width: (MediaQuery.of(context).size.width) * .75,
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 4.0, 0.0),
                              decoration: ShapeDecoration(
                                color: HexColor('FFFFFF'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(themeLayout.borderRadius),
                                    side: BorderSide(
                                      color: HexColor("E9EDF0"),
                                      width: 3.0,
                                    )),
                              ),
                              child: DropdownButtonFormField<String>(
                                iconSize:0.0,
                                isExpanded: true,
                                decoration: textInputDecoration,
                                hint: Text(
                                  "+ Tag",
                                  style: TextStyle(
                                    color: themeColor.secBlue,
                                    fontSize: 16,
                                  ),
                                ),
                                value: _tag.isNotEmpty ? _tag : null,
                                items: Tag.values.map((tag) {
                                  return DropdownMenuItem(
                                    value: tag.string,
                                    child: Text(
                                      tag.string,
                                      style: TextStyle(
                                        color: themeColor.neutralGrey,
                                        fontSize: 14,
                                        //fontWeight: ,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _tag = val!),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 12),
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
                              borderRadius: BorderRadius.circular(themeLayout.borderRadius),
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
                                color: themeColor.neutralGrey,
                                fontSize: 18,
                                //fontWeight: ,
                              ),
                              maxLines: null,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    color: HexColor("b5Babe"),
                                    fontSize: 18,
                                    //fontWeight: ,
                                  ),
                                  border: InputBorder.none,
                                  hintText: "optional text"),
                              validator: (val) {
                                if (val == null) return 'Error: null value';
                                if (val.isEmpty)
                                  return 'Can\'t create an empty post';
                                else
                                  return null;
                              },
                              onChanged: (val) => setState(() => _title = val),
                            )
                          ],
                        ),
                      ), //
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
