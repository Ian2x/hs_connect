import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
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
    Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => Home()),);
  }

  // form values
  String _title = '';
  String _text = '';
  String? _imageURL;
  String _groupId = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    } else {
      return FutureBuilder(
          future: _GroupsDatabaseService.getGroups(userGroups: userData.userGroups),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final groups = (snapshot.data as QuerySnapshot).docs.toList();
              return Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Create a new post',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 5.0),
                    Text('Post title'),
                    TextFormField(
                      initialValue: '',
                      decoration: textInputDecoration,
                      validator: (val) {
                        if (val == null) return 'Error: null value';
                        if (val.isEmpty)
                          return 'Can\'t create an empty post';
                        else
                          return null;
                      },
                      onChanged: (val) => setState(() => _title = val),
                    ),
                    SizedBox(height: 5.0),
                    Text('Post text'),
                    TextFormField(
                      initialValue: '',
                      decoration: textInputDecoration,
                      validator: (val) {
                        if (val == null) return 'Error: null value';
                        if (val.isEmpty)
                          return 'Can\'t create an empty post';
                        else
                          return null;
                      },
                      onChanged: (val) => setState(() => _text = val),
                    ),
                    SizedBox(height: 5.0),
                    Text('(optional) Image URL'),
                    TextFormField(
                      initialValue: '',
                      decoration: textInputDecoration,
                      validator: (val) {
                        if (val == null)
                          return 'Error: null value';
                        else
                          return null;
                      },
                      onChanged: (val) => setState(() => _imageURL = val),
                    ),
                    SizedBox(height: 5.0),
                    DropdownButtonFormField<String>(
                      decoration: textInputDecoration,
                      value: _groupId != '' ? _groupId : null,
                      items: groups.map((group) {
                        print(group);
                        return DropdownMenuItem(
                          value: group.id,
                          child: Text('${group['name']}'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _groupId = val!),
                      validator: (val) {
                        if (val == null)
                          return 'Must select an access restriction';
                        else
                          return null;
                      }
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.pink[400],
                        ),
                        onPressed: () async {
                          if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                            setState(() => loading = true);
                            await PostsDatabaseService(userId: user.uid).newPost(
                              title: _title,
                              text: _text,
                              imageURL: _imageURL,
                              groupId: _groupId,
                              onValue: handleValue,
                              onError: handleError,
                            );
                          }
                        },
                        child: Text(
                          'Make post',
                          style: TextStyle(color: Colors.white),
                        )),
                    SizedBox(height: 12.0),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              );
            } else {
              return Loading();
            }
          });
    }
  }
}
