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

    Widget buildSheet(){

      return Container(
        padding: EdgeInsets.fromLTRB( 20.0,0.0, 20.0, 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox( height:50),
            Text(
              "Pick a group",
              style: ThemeText.groupBold(
                color: ThemeColor.black, fontSize: 18,
              )
            ),
            Divider(color: ThemeColor.backgroundGrey, thickness:2),
            Row(
              children: [
                Text(
                    "Lawrenceville",
                    style: ThemeText.groupBold(
                      color: ThemeColor.darkGrey, fontSize: 16,
                    )
                ), Spacer(),
                ConstrainedBox(
                  constraints: BoxConstraints( maxHeight:40) ,
                  child: Checkbox(
                    checkColor: ThemeColor.white,
                    activeColor: ThemeColor.secondaryBlue,
                    tristate:true,
                    shape:CircleBorder(),
                    onChanged: (bool? value){
                      setState(() {
                      });
                    }, value: null,
                  ),
                )
              ]
            ),
            Text("Only for your school", style: ThemeText.groupBold(color: ThemeColor.mediumGrey, fontSize: 16)),
            SizedBox(height:5),
            Divider (color: ThemeColor.backgroundGrey, thickness:2),
            Row(
                children: [
                  Text(
                      "Lawrenceville",
                      style: ThemeText.groupBold(
                        color: ThemeColor.darkGrey, fontSize: 16,
                      )
                  ), Spacer(),
                  ConstrainedBox(
                    constraints: BoxConstraints( maxHeight:40) ,
                    child: Checkbox(
                      checkColor: ThemeColor.white,
                      activeColor: ThemeColor.secondaryBlue,
                      tristate:true,
                      shape:CircleBorder(),
                      onChanged: (bool? value){
                        setState(() {
                        });
                      }, value: null,
                    ),
                  )
                ]
            ),
            Text("Eveyrone can see", style: ThemeText.groupBold(color: ThemeColor.mediumGrey, fontSize: 16)),
          ],
        )
      );
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
                        TagOutline(
                          textOnly:false,
                          widget: TextButton(
                            onPressed:()=> showModalBottomSheet(context: context, builder: (context)=> buildSheet()),
                            child: Text("Lawrenceville"),
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
                    SizedBox(height: 6),
                    //Divider(height: MediaQuery.of(context).size.width, thickness:2,color: ThemeColor.backgroundGrey),
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
