import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/post.dart';
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
  final Post post;
  final bool isReply;
  final DocumentReference? commentReference;
  final VoidDocParamFunction switchFormBool;

  CommentReplyForm({Key? key,
    required this.currUserRef,
    required this.post,
    required this.isReply,
    required this.switchFormBool,
    required this.commentReference,
  }) : super(key: key);

  @override
  _CommentReplyFormState createState() => _CommentReplyFormState();
}

class _CommentReplyFormState extends State<CommentReplyForm> {
  late FocusNode myFocusNode;
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
      _comments = CommentsDatabaseService(currUserRef: widget.currUserRef, postRef: widget.post.postRef);
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
          postRef: widget.post.postRef,
          commentRef: widget.commentReference!,
          text: _text,
          media: newFileURL,
          onValue: handleValue,
          onError: handleError,
          groupRef: widget.post.groupRef,
          postCreatorRef: widget.post.creatorRef,
        );
      } else {
        await _comments!.newComment(
          postRef: widget.post.postRef,
          text: _text,
          media: newFileURL,
          onValue: handleValue,
          onError: handleError,
          groupRef: widget.post.groupRef,
          postCreatorRef: widget.post.creatorRef,
        );
      }
      _formKey.currentState?.reset();

    }
  }


  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null || _comments == null) {
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
          style: Theme.of(context).textTheme.subtitle1,
          autocorrect: false,
          decoration: commentReplyInputDecoration(
              context: context,
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
