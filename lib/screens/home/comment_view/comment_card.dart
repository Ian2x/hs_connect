import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/comment_view/comment_form.dart';
import 'package:hs_connect/screens/home/comment_view/like_dislike_comment.dart';
import 'package:hs_connect/screens/home/post_view/delete_post.dart';
import 'package:hs_connect/screens/home/post_view/like_dislike_post.dart';
import 'package:hs_connect/screens/home/post_view/post_page.dart';
import 'package:hs_connect/screens/home/reply_feed/reply_feed.dart';
import 'package:hs_connect/screens/home/reply_view/reply_form.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:flutter/foundation.dart';


class CommentCard extends StatefulWidget {
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference userRef;
  final String text;
  final String? media;
  final String createdAt;
  List<DocumentReference> likes;
  List<DocumentReference> dislikes;
  final DocumentReference currUserRef;

  CommentCard(
      {Key? key,
      required this.commentRef,
      required this.postRef,
      required this.userRef,
      required this.text,
      required this.media,
      required this.createdAt,
      required this.likes,
      required this.dislikes,
      required this.currUserRef})
      : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  UserInfoDatabaseService _userInfoDatabaseService = UserInfoDatabaseService();

  CommentsDatabaseService _comments = CommentsDatabaseService();

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.likes.contains(widget.currUserRef)) {
      setState(() {
        liked = true;
      });
    } else if (widget.likes.contains(widget.currUserRef)) {
      setState(() {
        disliked = true;
      });

    }
    // find username for userId
    // _userInfoDatabaseService.userId = widget.userId;
    getUsername();
    super.initState();
  }

  void getUsername() async {
    final UserData? fetchUsername = await _userInfoDatabaseService.getUserData(userRef: widget.userRef);
    setState(() {
      username = fetchUsername != null ? fetchUsername.displayedName : '<Failed to retrieve user name>';
    });
  }

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: ValueKey(widget.commentRef),
      child: Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
          title: Text(widget.text),
          subtitle: Text(username),
          trailing:
          LikeDislikeComment(
              commentRef: widget.commentRef,
              currUserRef: widget.currUserRef,
              likes: widget.likes,
              dislikes: widget.dislikes),

        ),
        widget.media!=null ? Semantics(
          label: 'new_profile_pic_picked_image',
          child: Image.network(widget.media!) // kIsWeb ? Image.network(widget.image!) : Image.file(File(widget.image!)),
        ) : Container(),
        RepliesFeed(commentRef: widget.commentRef),
      ])),
      onDismissed: (DismissDirection direction) {
        setState(() {
          _comments.deleteComment(commentRef: widget.commentRef, userRef: widget.currUserRef, media: widget.media);
        });
      },
    );
  }
}
