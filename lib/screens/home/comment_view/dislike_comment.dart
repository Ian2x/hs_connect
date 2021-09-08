import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/services/comments_database.dart';
import 'package:hs_connect/Backend/services/posts_database.dart';

class DislikeComment extends StatefulWidget {
  final String currUserId;
  final String commentId;
  final List<String> dislikes;

  const DislikeComment({Key? key, required this.currUserId, required this.commentId, required this.dislikes})
      : super(key: key);

  @override
  _DislikeCommentState createState() => _DislikeCommentState();
}

class _DislikeCommentState extends State<DislikeComment> {
  CommentsDatabaseService _comments = CommentsDatabaseService();

  bool dislikeStatus = false; // either liked, disliked, or empty

  @override
  void initState() {
    setState(() {
      setState(() {
        dislikeStatus = widget.dislikes.toList().contains(widget.currUserId);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (dislikeStatus == true) {
      return IconButton(
        iconSize: 20.0,
        icon: Icon(Icons.thumb_down),
        onPressed: () {
          _comments.unDislikeComment(commentId: widget.commentId, userId: widget.currUserId);
          setState(() {
            dislikeStatus = false;
          });
        },
      );
    } else {
      return IconButton(
        iconSize: 20.0,
        icon: Icon(Icons.thumb_down_outlined),
        onPressed: () {
          _comments.dislikeComment(commentId: widget.commentId, userId: widget.currUserId);
          setState(() {
            dislikeStatus = true;
          });
        },
      );
    }
  }
}
