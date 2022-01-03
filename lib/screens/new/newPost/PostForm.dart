import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/widgets/tagOutline.dart';
import 'package:provider/provider.dart';

class PostForm extends StatefulWidget {
  const PostForm({Key? key}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();

  final _GroupsDatabaseService = GroupsDatabaseService();

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

  // form values
  String _title = '';
  String _text = '';
  String _groupId = '';
  String _tag = '';
  String error = '';
  bool loading = false;

  ImageStorage _images = ImageStorage();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    double phoneHeight = MediaQuery.of(context).size.height - 200;

    final userData = Provider.of<UserData?>(context);

    void setPic(File x) {
      setState(() {
        newFile = x;
      });
    }

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    } else {
      return FutureBuilder(
          future: _GroupsDatabaseService.getGroups(userGroups: userData.userGroups),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final groups = (snapshot.data as QuerySnapshot).docs.toList();
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 100),
                      Row(
                        children: [
                          tagOutline(textOnly: true, text: "button"),
                          SizedBox(width: 20),
                          tagOutline(textOnly: true, text: "Group"),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Container(
                              height: 70,
                              width: (MediaQuery.of(context).size.width) * .75,
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 3.0, 0.0),
                              decoration: ShapeDecoration(
                                color: HexColor('FFFFFF'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13.0),
                                    side: BorderSide(
                                      color: HexColor("E9EDF0"),
                                      width: 3.0,
                                    )),
                              ),
                              child: DropdownButtonFormField<String>(
                                  decoration: textInputDecoration,
                                  hint: Text(
                                    "Post to a group",
                                    style: TextStyle(
                                      color: HexColor("B5BABE"),
                                      fontSize: 16,
                                    ),
                                  ),
                                  value: _groupId != '' ? _groupId : null,
                                  items: groups.map((group) {
                                    return DropdownMenuItem(
                                      value: group.id,
                                      child: Text(
                                        '${group['name']}',
                                        style: TextStyle(
                                          color: HexColor("B5BABE"),
                                          fontSize: 14,
                                          //fontWeight: ,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _groupId = val!),
                                  validator: (val) {
                                    if (val == null)
                                      return 'Must select an access restriction';
                                    else
                                      return null;
                                  }),
                            ),
                          ),
                          SizedBox(width: 12),
                          Flexible(
                            flex: 1,
                            child: Container(
                              height: 70,
                              width: (MediaQuery.of(context).size.width) * .75,
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 3.0, 0.0),
                              decoration: ShapeDecoration(
                                color: HexColor('FFFFFF'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    side: BorderSide(
                                      color: HexColor("E9EDF0"),
                                      width: 3.0,
                                    )),
                              ),
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: textInputDecoration,
                                hint: Text(
                                  "+ tag",
                                  style: TextStyle(
                                    color: HexColor("B5BABE"),
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
                              borderRadius: BorderRadius.circular(13.0),
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
              return Loading();
            }
          });
    }
  }
}
