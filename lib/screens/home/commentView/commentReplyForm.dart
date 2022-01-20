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

class CommentReplyForm extends StatefulWidget {
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final bool isReply;
  final DocumentReference? commentReference;
  final voidDocParamFunction switchFormBool;

  CommentReplyForm({Key? key,
    required this.postRef,
    required this.groupRef,
    required this.isReply,
    required this.switchFormBool,
    this.commentReference,
  }) : super(key: key);

  @override
  _CommentReplyFormState createState() => _CommentReplyFormState();
}

class _CommentReplyFormState extends State<CommentReplyForm> {
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
          Form(
            key:_formKey,
            child: TextFormField(
              initialValue: '',
              decoration: commentReplyInputDecoration(
                  isReply: widget.isReply,
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

                      if (widget.isReply){
                        widget.switchFormBool(null);
                        await RepliesDatabaseService(currUserRef: userData.userRef).newReply(
                          postRef: widget.postRef,
                          commentRef: widget.commentReference!,
                          text: _text,
                          media: newFileURL,
                          onValue: handleValue,
                          onError: handleError,
                          groupRef: widget.groupRef,
                        );
                      } else {
                        await _comments.newComment(
                          postRef: widget.postRef,
                          text: _text,
                          media: newFileURL,
                          onValue: handleValue,
                          onError: handleError,
                          groupRef: widget.groupRef,
                        );
                      }
                    }
                    _formKey.currentState?.reset();
                  },
                  setPic: setPic),
              validator:
                widget.isReply!= false ? (val) {
                    if (val == null) return 'Write a reply...';
                    if (val.isEmpty)
                      return 'Can\'t create an empty reply';
                    else
                  return null;
                  }
                : (val) {
                  if (val == null) return 'Write a comment...';
                  if (val.isEmpty)
                    return 'Can\'t create an empty comment';
                  else
                    return null;
                }
               ,
              onChanged: (val) {
                if (mounted) {
                  setState(() => _text = val);
                }
              },
            ),
          )
      );
  }
}
