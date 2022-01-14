import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class CommentForm extends StatefulWidget {
  final DocumentReference postRef;
  final DocumentReference groupRef;

  const CommentForm({Key? key, required this.postRef, required this.groupRef}) : super(key: key);

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
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

  void setPic(File newFile2) {
    if (mounted) {
      setState(() {
        newFile = newFile2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    }

    CommentsDatabaseService _comments = CommentsDatabaseService(currUserRef: userData.userRef, postRef: widget.postRef);

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: '',
            decoration: commentInputDecoration(
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

                    await _comments.newComment(
                      postRef: widget.postRef,
                      text: _text,
                      media: newFileURL,
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
                return 'Can\'t create an empty comment';
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
