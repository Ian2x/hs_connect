import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/shared/widgets/thick_arrow_icons.dart';

class LikeDislikeReply extends StatefulWidget {
  final DocumentReference currUserRef;
  final Reply reply;
  final Color? currUserColor;

  const LikeDislikeReply({Key? key, required this.currUserRef, required this.reply, required this.currUserColor}) : super(key: key);

  @override
  _LikeDislikeReplyState createState() => _LikeDislikeReplyState();
}

class _LikeDislikeReplyState extends State<LikeDislikeReply> {
  bool likeStatus = false;
  bool dislikeStatus = false;
  int likeCount = 0;
  int dislikeCount = 0;
  static const double iconSize = 20;

  @override
  void initState() {
    if (mounted) {
      setState(() {
        likeStatus = widget.reply.likes.contains(widget.currUserRef);
        dislikeStatus = widget.reply.dislikes.contains(widget.currUserRef);
        likeCount = widget.reply.likes.length;
        dislikeCount = widget.reply.dislikes.length;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    final colorScheme = Theme.of(context).colorScheme;

    RepliesDatabaseService _replies = RepliesDatabaseService(
        currUserRef: widget.currUserRef,
        replyRef: widget.reply.replyRef,
        commentRef: widget.reply.commentRef,
        postRef: widget.reply.postRef);

    Color activeColor = widget.currUserColor!=null ? widget.currUserColor! : colorScheme.secondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            () {
          if (likeStatus == true) {
            return IconButton(
              iconSize: iconSize,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints(),
              icon: Icon(ThickArrow.angle_up_icon, color: activeColor),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _replies.unLikeReply(widget.reply.creatorRef!);
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
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints(),
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
                _replies.likeReply(widget.reply.creatorRef!, likeCount);
              },
            );
          }
        }(),
        SizedBox(width: 2),
        Text(
          (likeCount - dislikeCount).toString(),
          style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: 0.8 * iconSize)
        ),
        SizedBox(width: 2),
            () {
          if (dislikeStatus == true) {
            return IconButton(
              iconSize: iconSize,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints(),
              icon: Icon(ThickArrow.angle_down_icon, color: activeColor),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _replies.unDislikeReply();
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
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints(),
              icon: Icon(ThickArrow.angle_down_icon),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _replies.dislikeReply();
                if (mounted) {
                  setState(() {
                    dislikeCount += 1;
                    if (likeStatus == true) likeCount -= 1;
                    dislikeStatus = true;
                    likeStatus = false;
                  });
                }
              },
            );
          }
        }(),
      ],
    );
  }
}
