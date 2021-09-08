import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:provider/provider.dart';

class CommentForm extends StatefulWidget {
  final String postId;

  const CommentForm({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _formKey = GlobalKey<FormState>();

  void handleError(err) {
    setState(() {
      error = 'ERROR: something went wrong, possibly with username to email conversion';
    });
  }

  void handleValue(val) {
    loading = false;
  }

  // form values
  String _text = '';
  String? _imageURL;
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
      return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              initialValue: '',
              decoration: messageInputDecoration(onPressed: () async {
                if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                  setState(() => loading = true);
                  await CommentsDatabaseService(userId: user.uid).newComment(
                    postId: widget.postId,
                    text: _text,
                    imageURL: _imageURL,
                    onValue: handleValue,
                    onError: handleError,
                  );
                }
              }),
              validator: (val) {
                if (val == null) return 'Error: null value';
                if (val.isEmpty)
                  return 'Can\'t create an empty comment';
                else
                  return null;
              },
              onChanged: (val) => setState(() => _text = val),
            ),
            Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 14.0),
            )
          ],
        ),
      );
    }
  }
}
