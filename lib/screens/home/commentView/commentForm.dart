import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/tools/formListener.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class CommentForm extends StatefulWidget {
  final DocumentReference postRef;
  final DocumentReference groupRef;
  formListener FormListener;

  CommentForm({Key? key,
    required this.postRef,
    required this.groupRef,
    required this.FormListener,
  }) : super(key: key);

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

    return Container(
        width: MediaQuery.of(context).size.width,
        //height: 100,
        color: ThemeColor.backgroundGrey,
        child:
        widget.FormListener.isReply !=null ?
          Form(
            key:_formKey,
            child: TextFormField(
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
          )
        :
      Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: 'REPLY',
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

                    await RepliesDatabaseService(currUserRef: userData.userRef).newReply(
                      postRef: widget.postRef,
                      commentRef: widget.FormListener.commentReference!,
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
    ),
      );
  }
}

/*
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
 */
