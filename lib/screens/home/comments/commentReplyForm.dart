import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentReplyForm extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final bool isReply;
  final DocumentReference? commentReference;
  final DocumentReference postCreatorRef;
  final VoidDocParamFunction switchFormBool;
  final double hp;
  final double wp;

  CommentReplyForm({Key? key,
    required this.currUserRef,
    required this.postRef,
    required this.groupRef,
    required this.isReply,
    required this.switchFormBool,
    required this.commentReference,
    required this.postCreatorRef,
    required this.hp,
    required this.wp,
  }) : super(key: key);

  @override
  _CommentReplyFormState createState() => _CommentReplyFormState();
}

class _CommentReplyFormState extends State<CommentReplyForm> {
  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

  double? hp;
  double? wp;

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
  CommentsDatabaseService? _comments;


  void setPic(File newFile2) {
    if (mounted) {
      setState(() {
        newFile = newFile2;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    if (mounted) setState(() {
      wp = widget.wp;
      hp = widget.hp;
      _comments = CommentsDatabaseService(currUserRef: widget.currUserRef, postRef: widget.postRef);
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }

  void onSubmit() async {
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
        await RepliesDatabaseService(currUserRef: widget.currUserRef).newReply(
          postRef: widget.postRef,
          commentRef: widget.commentReference!,
          text: _text,
          media: newFileURL,
          onValue: handleValue,
          onError: handleError,
          groupRef: widget.groupRef,
          postCreatorRef: widget.postCreatorRef,
        );
      } else {
        await _comments!.newComment(
          postRef: widget.postRef,
          text: _text,
          media: newFileURL,
          onValue: handleValue,
          onError: handleError,
          groupRef: widget.groupRef,
          postCreatorRef: widget.postCreatorRef,
        );
      }
      _formKey.currentState?.reset();

    }
  }


  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null || _comments == null || wp == null || hp == null) {
      return Loading();
    }

    return
      Form(
        key:_formKey,
        child: TextFormField(
          maxLines: null,
          initialValue: '',
          focusNode: myFocusNode,
          /*onFieldSubmitted: (value) {
            // was working on submitting upon "enter" key press, but probably not necessary/wanted
            onSubmit();
          },*/
          style: TextStyle(

          ),
          autocorrect: false,
          decoration: commentReplyInputDecoration(
              wp: wp!,
              hp: hp!,
              isReply: widget.isReply,
              onPressed: () async {
                onSubmit();
              },
              setPic: setPic, isFocused: myFocusNode.hasFocus),
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
      );
  }
}
