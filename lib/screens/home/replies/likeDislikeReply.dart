import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/shared/constants.dart';

const double iconSize = 25;
const EdgeInsets iconPadding = EdgeInsets.all(3.0);

class LikeDislikeReply extends StatefulWidget {
  final DocumentReference currUserRef;
  final Reply reply;

  const LikeDislikeReply({Key? key, required this.currUserRef, required this.reply}) : super(key: key);

  @override
  _LikeDislikeReplyState createState() => _LikeDislikeReplyState();
}

class _LikeDislikeReplyState extends State<LikeDislikeReply> {
  bool likeStatus = false;
  bool dislikeStatus = false;
  int likeCount = 0;
  int dislikeCount = 0;

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
    RepliesDatabaseService _replies = RepliesDatabaseService(
        currUserRef: widget.currUserRef,
        replyRef: widget.reply.replyRef,
        commentRef: widget.reply.commentRef,
        postRef: widget.reply.postRef);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        () {
          if (dislikeStatus == true) {
            return IconButton(
              iconSize: iconSize,
              splashColor: Colors.transparent,
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: ThemeColor.secondaryBlue,
              icon: Icon(Icons.keyboard_arrow_down_rounded),
              onPressed: () {
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
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: ThemeColor.darkGrey,
              icon: Icon(Icons.keyboard_arrow_down_rounded),
              onPressed: () {
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
        Text(
          (likeCount - dislikeCount).toString(),
          style: ThemeText.inter(fontSize: 14)
        ),
        () {
          if (likeStatus == true) {
            return IconButton(
              iconSize: iconSize,
              splashColor: Colors.transparent,
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: ThemeColor.secondaryBlue,
              icon: Icon(Icons.keyboard_arrow_up_rounded, color: ThemeColor.secondaryBlue),
              onPressed: () {
                _replies.unLikeReply();
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
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: ThemeColor.darkGrey,
              icon: Icon(Icons.keyboard_arrow_up_rounded),
              onPressed: () {
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
      ],
    );
  }
}
