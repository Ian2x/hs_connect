import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/screens/home/commentView/likeDislikeComment.dart';
import 'package:hs_connect/screens/home/replyFeed/replyFeed.dart';
import 'package:hs_connect/services/user_data_database.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final DocumentReference currUserRef;

  CommentCard({
    Key? key,
    required this.comment,
    required this.currUserRef,
  }) : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService();

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.comment.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          liked = true;
        });
      }
    } else if (widget.comment.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          disliked = true;
        });
      }
    }
    getUsername();
    super.initState();
  }

  void getUsername() async {
    if (widget.comment.creatorRef != null) {
      final UserData? fetchUsername = await _userDataDatabaseService.getUserData(userRef: widget.comment.creatorRef);
      if (mounted) {
        setState(() {
          username = fetchUsername != null ? fetchUsername.displayedName : '<Failed to retrieve user name>';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          username = '[Removed]';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      ListTile(
        title: Text(widget.comment.text),
        subtitle: Text(username),
        trailing: LikeDislikeComment(
            commentRef: widget.comment.commentRef,
            currUserRef: widget.currUserRef,
            likes: widget.comment.likes,
            dislikes: widget.comment.dislikes),
      ),
      RepliesFeed(commentRef: widget.comment.commentRef, postRef: widget.comment.postRef, groupRef: widget.comment.groupRef),
    ]));
  }
}
