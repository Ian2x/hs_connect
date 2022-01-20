import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';

const double iconSize = 32;

const EdgeInsets iconPadding = EdgeInsets.all(0);

class LikeDislikePost extends StatefulWidget {
  final DocumentReference currUserRef;
  final Post post;

  const LikeDislikePost(
      {Key? key, required this.currUserRef, required this.post})
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
        likeStatus = widget.post.likes.contains(widget.currUserRef);
        dislikeStatus = widget.post.dislikes.contains(widget.currUserRef);
        likeCount = widget.post.likes.length;
        dislikeCount = widget.post.dislikes.length;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.currUserRef, postRef: widget.post.postRef);

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
                _posts.unDislikePost();
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
                _posts.dislikePost();
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
          style: ThemeText.inter(fontSize: 16),
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
                _posts.unLikePost();
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
                _posts.likePost(widget.post.creatorRef, likeCount);
              },
            );
          }
        }()
      ],
    );
  }
}
