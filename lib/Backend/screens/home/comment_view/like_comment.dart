import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/services/comments_database.dart';
import 'package:hs_connect/Backend/services/posts_database.dart';

class LikeComment extends StatefulWidget {
  final String currUserId;
  final String commentId;
  final List<String> likes;

  const LikeComment({Key? key, required this.currUserId, required this.commentId, required this.likes})
      : super(key: key);

  @override
  _LikeCommentState createState() => _LikeCommentState();
}

class _LikeCommentState extends State<LikeComment> {
  CommentsDatabaseService _comments = CommentsDatabaseService();

  bool likeStatus = false; // either liked, disliked, or empty

  @override
  void initState() {
    setState(() {
      setState(() {
        likeStatus = widget.likes.toList().contains(widget.currUserId);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (likeStatus == true) {
      return IconButton(
        iconSize: 20.0,
        icon: Icon(Icons.thumb_up),
        onPressed: () {
          _comments.unLikeComment(commentId: widget.commentId, userId: widget.currUserId);
          setState(() {
            likeStatus = false;
          });
        },
      );
    } else {
      return IconButton(
        iconSize: 20.0,
        icon: Icon(Icons.thumb_up_outlined),
        onPressed: () {
          _comments.likeComment(commentId: widget.commentId, userId: widget.currUserId);
          setState(() {
            likeStatus = true;
          });
        },
      );
    }
  }
}
