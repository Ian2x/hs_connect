import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/replies_database.dart';

class LikeDislikeReply extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference replyRef;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;

  const LikeDislikeReply(
      {Key? key, required this.currUserRef, required this.replyRef, required this.likes, required this.dislikes})
      : super(key: key);

  @override
  _LikeDislikeReplyState createState() => _LikeDislikeReplyState();
}

class _LikeDislikeReplyState extends State<LikeDislikeReply> {
  RepliesDatabaseService _replies = RepliesDatabaseService();

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        () {
          if (likeStatus == true) {
            return IconButton(
              iconSize: 20.0,
              icon: Icon(Icons.thumb_up),
              onPressed: () {
                _replies.unLikeReply(replyRef: widget.replyRef, userRef: widget.currUserRef);
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
              icon: Icon(Icons.thumb_up_outlined),
              onPressed: () {
                _replies.likeReply(replyRef: widget.replyRef, userRef: widget.currUserRef);
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
              icon: Icon(Icons.thumb_down),
              onPressed: () {
                _replies.unDislikeReply(replyRef: widget.replyRef, userRef: widget.currUserRef);
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
              icon: Icon(Icons.thumb_down_outlined),
              onPressed: () {
                _replies.dislikeReply(replyRef: widget.replyRef, userRef: widget.currUserRef);
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
        }()
      ],
    );
  }
}
