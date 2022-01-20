import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/home/new/newPost/postBar.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/noAnimationMaterialPageRoute.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
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
    if (mounted) {
      setState(() {
        error = 'ERROR: something went wrong, possibly with username to email conversion';
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

  String? newFileURL;
  File? newFile;

  // form values
  String _title = '';
  String _text = '';
  DocumentReference? _groupRef = null;
  String _tag = '';
  String error = '';
  bool loading = false;

  bool hasPic = false;
  bool hasPoll = false;

  ImageStorage _images = ImageStorage();

  addImage (File? imageFile){
    setState((){
      hasPic=true;
      if (imageFile != null){
        if (mounted) {
          newFile = imageFile;
        }
      }
    });
  }

  addPoll (){
    setState((){
      hasPoll=true;
    });
  }


  @override
  Widget build(BuildContext context) {
    double phoneHeight = MediaQuery.of(context).size.height - 200;


    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    }

    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: userData.userRef);

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    }

    void submitForm() async {
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        if (mounted) {
          setState(() => loading = true);
        }
        if (newFile != null) {
          // upload newFile
          final downloadURL = await _images.uploadImage(file: newFile!);
          if (mounted) {
            setState(() {
              newFileURL = downloadURL;
            });
          }
        }
        await PostsDatabaseService(currUserRef: userData.userRef).newPost(
          title: _title,
          text: _text,
          tagString: _tag,
          media: newFileURL,
          pollRef: null,
          //until poll is implemented
          groupRef: _groupRef!,
          onValue: handleValue,
          onError: handleError,
        );
      }

    }


    return
      Stack(
      children:[
      postBar(
        addImage: addImage,
        addPoll: addPoll,
      ),
      FutureBuilder(
        future: _groups.getGroups(groupsRefs: userData.groups, withPublic: true),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final nullGroups = snapshot.data as List<Group?>;
            List<Group> groups = [];
            for (Group? group in nullGroups) {
              if (group != null) {
                groups.add(group);
              }
            }
            groups.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 50), //TODO: Find media height
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //Top ROW
                      children: [
                        SizedBox(height:50),
                        TextButton(
                          child: Text(
                            "Cancel", style: ThemeText.regularSmall(color: ThemeColor.mediumGrey,fontSize: 16)
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              NoAnimationMaterialPageRoute(builder: (context) => Home()),
                            );
                          },
                        ),
                        Spacer(),
                        Container(
                          color: ThemeColor.backgroundGrey,
                          width:200,
                          height:50,
                          child:
                          Theme(
                            data:Theme.of(context).copyWith(canvasColor: Colors.blue),

                            child: DropdownButtonFormField<DocumentReference>(
                                iconSize: 6.0,
                                icon: Icon(Icons.keyboard_arrow_down_rounded),
                                elevation:0,
                                dropdownColor: ThemeColor.backgroundGrey,
                                itemHeight: 48.0,
                                isExpanded: true,
                                decoration: textInputDecoration,
                                hint: Text(
                                  "Visibility",
                                  style: ThemeText.groupBold(
                                    color: ThemeColor.black,
                                    fontSize: 18,
                                  ),
                                ),
                                value: _groupRef != null ? _groupRef : null,
                                items: groups.map((group) {
                                  return DropdownMenuItem(
                                    value: group.groupRef,
                                    child: Text(
                                      group.name,
                                      style: ThemeText.groupBold(
                                        color: ThemeColor.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (mounted) {
                                    setState(() => _groupRef = val!);
                                  }
                                },
                                validator: (val) {
                                  if (val == null)
                                    return 'Pick a group to post to';
                                  else
                                    return null;
                                }),
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          child: Text(
                            "Post",
                            style: ThemeText.regularSmall(color: ThemeColor.secondaryBlue, fontSize: 16),
                          ),
                          onPressed: submitForm,),
                      ],
                    ),
                    SizedBox(height: 15),
                    hasPic != false ? SizedBox(height: 10) : SizedBox(),
                    hasPic != false ? imagePreview(fileImage: newFile) : SizedBox(),
                    hasPic != false ? SizedBox(height: 10) : SizedBox(),
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
            return Loading();
          }
        })
    ]);
  }
}
