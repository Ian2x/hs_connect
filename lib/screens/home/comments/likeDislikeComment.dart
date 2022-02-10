import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/arrows_icons.dart';
import 'package:provider/provider.dart';

class LikeDislikeComment extends StatefulWidget {
  final DocumentReference currUserRef;
  final Comment comment;

  const LikeDislikeComment({Key? key, required this.currUserRef, required this.comment}) : super(key: key);

  @override
  _LikeDislikeCommentState createState() => _LikeDislikeCommentState();
}

class _LikeDislikeCommentState extends State<LikeDislikeComment> {
  static const double iconSize = 15;
  bool likeStatus = false;
  bool dislikeStatus = false;
  int likeCount = 0;
  int dislikeCount = 0;

  @override
  void initState() {
    if (mounted) {
      setState(() {
        likeStatus = widget.comment.likes.contains(widget.currUserRef);
        dislikeStatus = widget.comment.dislikes.contains(widget.currUserRef);
        likeCount = widget.comment.likes.length;
        dislikeCount = widget.comment.dislikes.length;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    CommentsDatabaseService _comments = CommentsDatabaseService(
        currUserRef: widget.currUserRef, commentRef: widget.comment.commentRef, postRef: widget.comment.postRef);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            () {
          if (likeStatus == true) {
            return IconButton(
              iconSize: iconSize,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(3*hp),
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Arrows.up_open_big, color: colorScheme.secondary),
              onPressed: () {
                _comments.unLikeComment(widget.comment.creatorRef!);
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
              iconSize: iconSize,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(3*hp),
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(Arrows.up_open_big),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    likeCount += 1;
                    if (dislikeStatus == true) dislikeCount -= 1;
                    likeStatus = true;
                    dislikeStatus = false;
                  });
                }
                _comments.likeComment(widget.comment.creatorRef!, likeCount);
              },
            );
          }
        }(),
        SizedBox(width: 3*wp),
        Text(
          (likeCount - dislikeCount).toString(),
          style: Theme.of(context).textTheme.subtitle2
        ),
        SizedBox(width: 3*wp),
            () {
          if (dislikeStatus == true) {
            return IconButton(
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(3*hp),
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Arrows.down_open_big, color: colorScheme.secondary),
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
              iconSize: iconSize,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(3*hp),
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(Arrows.down_open_big),
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
        }(),
      ],
    );
  }
}
