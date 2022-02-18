import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/thick_arrow_icons.dart';
import 'package:provider/provider.dart';

class LikeDislikeComment extends StatefulWidget {
  final DocumentReference currUserRef;
  final Comment comment;
  final Color? currUserColor;

  const LikeDislikeComment({Key? key, required this.currUserRef, required this.comment, required this.currUserColor}) : super(key: key);

  @override
  _LikeDislikeCommentState createState() => _LikeDislikeCommentState();
}

class _LikeDislikeCommentState extends State<LikeDislikeComment> {
  static const double iconSize = 18;
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

    Color activeColor = widget.currUserColor!=null ? widget.currUserColor! : colorScheme.secondary;

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
              icon: Icon(ThickArrow.angle_up_icon, color: activeColor),
              onPressed: () {
                HapticFeedback.heavyImpact();
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
              icon: Icon(ThickArrow.angle_up_icon),
              onPressed: () {
                HapticFeedback.heavyImpact();
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
        SizedBox(width: 8*wp),
        Text(
          (likeCount - dislikeCount).toString(),
          style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: 0.75 * iconSize * hp)
        ),
        SizedBox(width: 8*wp),
            () {
          if (dislikeStatus == true) {
            return IconButton(
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(3*hp),
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(ThickArrow.angle_down_icon, color: activeColor),
              onPressed: () {
                HapticFeedback.heavyImpact();
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
              icon: Icon(ThickArrow.angle_down_icon),
              onPressed: () {
                HapticFeedback.heavyImpact();
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
