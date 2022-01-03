import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:provider/provider.dart';

class ReplyForm extends StatefulWidget {
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference groupRef;

  const ReplyForm({Key? key, required this.commentRef, required this.postRef, required this.groupRef})
      : super(key: key);

  @override
  _ReplyFormState createState() => _ReplyFormState();
}

class _ReplyFormState extends State<ReplyForm> {
  final _formKey = GlobalKey<FormState>();

  void handleError(err) {
    if (mounted) {
      setState(() {
        error = 'ERROR: something went wrong :(';
      });
    }
  }

  void handleValue(val) {
    loading = false;
  }

  String? newFileURL;
  File? newFile;

  // form values
  String _text = '';
  String error = '';
  bool loading = false;

  ImageStorage _images = ImageStorage();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    final userData = Provider.of<UserData?>(context);

    void setPic(File newFile2) {
      if (mounted) {
        setState(() {
          newFile = newFile2;
        });
      }
    }

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
              decoration: messageInputDecoration(
                  onPressed: () async {
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

                      await RepliesDatabaseService(userRef: userData.userRef).newReply(
                        commentRef: widget.commentRef,
                        postRef: widget.postRef,
                        text: _text,
                        mediaURL: newFileURL,
                        onValue: handleValue,
                        onError: handleError,
                        groupRef: widget.groupRef,
                      );
                    }
                  },
                  setPic: setPic),
              validator: (val) {
                if (val == null) return 'Error: null value';
                if (val.isEmpty)
                  return 'Can\'t create an empty reply';
                else
                  return null;
              },
              onChanged: (val) {
                if (mounted) {
                  setState(() => _text = val);
                }
              },
            ),
            newFile != null
                ? Semantics(
                    label: 'new_profile_pic_picked_image',
                    child: kIsWeb ? Image.network(newFile!.path) : Image.file(File(newFile!.path)),
                  )
                : Container(),
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
