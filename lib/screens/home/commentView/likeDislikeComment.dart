import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/comments_database.dart';

const double iconSize = 10;
const EdgeInsets iconPadding = EdgeInsets.all(0);

class LikeDislikeComment extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference commentRef;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;

  const LikeDislikeComment(
      {Key? key, required this.currUserRef, required this.commentRef, required this.likes, required this.dislikes})
      : super(key: key);

  @override
  _LikeDislikeCommentState createState() => _LikeDislikeCommentState();
}

class _LikeDislikeCommentState extends State<LikeDislikeComment> {

  bool likeStatus = false;
  bool dislikeStatus = false;
  int likeCount = 0;
  int dislikeCount = 0;

  @override
  void initState() {
    if (mounted) {
      setState(() {
        likeStatus = widget.likes.contains(widget.currUserRef);
        dislikeStatus = widget.dislikes.contains(widget.currUserRef);
        likeCount = widget.likes.length;
        dislikeCount = widget.dislikes.length;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    CommentsDatabaseService _comments = CommentsDatabaseService(currUserRef: widget.currUserRef, commentRef: widget.commentRef);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        () {
          if (likeStatus == true) {
            return IconButton(
              iconSize: 20.0,
              icon: Icon(Icons.keyboard_arrow_up_rounded),
              onPressed: () {
                _comments.unLikeComment();
                if (mounted) {
                  setState(() {
                    likeCount -= 1;
                    likeStatus = false;
                  });
                }
              },
            );
          } else {
            return IconButton(
              iconSize: 20.0,
              icon: Icon(Icons.keyboard_arrow_up_rounded),
              onPressed: () {
                _comments.likeComment();
                if (mounted) {
                  setState(() {
                    likeCount += 1;
                    if (dislikeStatus == true) dislikeCount -= 1;
                    likeStatus = true;
                    dislikeStatus = false;
                  });
                }
              },
            );
          }
        }(),
        Text((likeCount - dislikeCount).toString()),
        () {
          if (dislikeStatus == true) {
            return IconButton(
              iconSize: 20.0,
              icon: Icon(Icons.keyboard_arrow_down_rounded),
              onPressed: () {
                _comments.unDislikeComment();
                if (mounted) {
                  setState(() {
                    dislikeCount -= 1;
                    dislikeStatus = false;
                  });
                }
              },
            );
          } else {
            return IconButton(
              iconSize: 20.0,
              icon: Icon(Icons.keyboard_arrow_up_rounded),
              onPressed: () {
                _comments.dislikeComment();
                setState(() {
                  dislikeCount += 1;
                  if (likeStatus == true) likeCount -= 1;
                  dislikeStatus = true;
                  likeStatus = false;
                });
              },
            );
          }
        }()
      ],
    );
  }
}
