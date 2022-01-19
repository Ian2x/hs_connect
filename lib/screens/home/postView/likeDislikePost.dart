import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';

const double iconSize = 32;
const EdgeInsets iconPadding = EdgeInsets.all(0);

class LikeDislikePost extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference postRef;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;

  const LikeDislikePost(
      {Key? key, required this.currUserRef, required this.postRef, required this.likes, required this.dislikes})
      : super(key: key);

  @override
  _LikeDislikePostState createState() => _LikeDislikePostState();
}

class _LikeDislikePostState extends State<LikeDislikePost> {
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
    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.currUserRef);

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
                _posts.unDislikePost(postRef: widget.postRef);
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
                _posts.dislikePost(postRef: widget.postRef);
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
        SizedBox(width: 5),
        Text(
          (likeCount - dislikeCount).toString(),
          style: ThemeText.regularSmall(fontSize: 16),
        ),
        SizedBox(width: 5),
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
                _posts.unLikePost(postRef: widget.postRef);
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
                _posts.likePost(postRef: widget.postRef);
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
        }()
      ],
    );
  }
}
