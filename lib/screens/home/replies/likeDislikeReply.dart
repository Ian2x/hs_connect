import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/arrows_icons.dart';
import 'package:provider/provider.dart';

const double iconSize = 14;

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
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

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
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(3*hp),
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Arrows.down_open_big, color: colorScheme.secondary),
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
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(3*hp),
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(Arrows.down_open_big),
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
        SizedBox(width: 5*wp),
        Text(
          (likeCount - dislikeCount).toString(),
          style: Theme.of(context).textTheme.subtitle2
        ),
        SizedBox(width: 5*wp),
        () {
          if (likeStatus == true) {
            return IconButton(
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(3*hp),
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Arrows.up_open_big, color: colorScheme.secondary),
              onPressed: () {
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
              iconSize: iconSize*hp,
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
                _replies.likeReply(widget.reply.creatorRef!, likeCount);
              },
            );
          }
        }(),
      ],
    );
  }
}
