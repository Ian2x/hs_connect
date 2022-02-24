import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentReplyForm extends StatefulWidget {
  final DocumentReference currUserRef;
  final Post post;
  final bool isReply;
  final Comment? comment;
  final VoidOptionalCommentParamFunction switchFormBool;
  final FocusNode focusNode;

  CommentReplyForm({Key? key,
    required this.currUserRef,
    required this.post,
    required this.isReply,
    required this.switchFormBool,
    required this.comment,
    required this.focusNode,
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
  CommentsDatabaseService? _comments;

  @override
  void initState() {
    super.initState();
    if (mounted) setState(() {
      _comments = CommentsDatabaseService(currUserRef: widget.currUserRef, postRef: widget.post.postRef);
    });
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
          post: widget.post,
          commentRef: widget.comment!.commentRef,
          text: _text,
          media: newFileURL,
          onValue: handleValue,
          onError: handleError,
          groupRef: widget.post.groupRef,
          commentCreatorRef: widget.comment!.creatorRef!,
        );
      } else {
        await _comments!.newComment(
          post: widget.post,
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
          focusNode: widget.focusNode,
          style: Theme.of(context).textTheme.bodyText1,
          textCapitalization: TextCapitalization.sentences,
          autocorrect: true,
          decoration: commentReplyInputDecoration(
              context: context,
              isReply: widget.isReply,
              activeColor: userData.domainColor ?? Theme.of(context).colorScheme.secondary,
              onPressed: () async {
                if (_text!=''){
                  onSubmit();
                }
                dismissKeyboard(context);
              },
              isFocused: widget.focusNode.hasFocus, hasText: _text!=''),
          onChanged: (val) {
            if (mounted) {
              setState(() => _text = val);
            }
          },
        ),
      );
  }
}
