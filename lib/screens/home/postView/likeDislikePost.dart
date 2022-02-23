import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/services/posts_database.dart';

import 'package:hs_connect/shared/widgets/thick_arrow_icons.dart';

const double postIconSizeStateless = 20;
const double postIconSizeStateful = 25;

class LikeDislikePost extends StatelessWidget {
  final DocumentReference currUserRef;
  final Post post;
  final PostLikesManager postLikesManager;
  final Color? currUserColor;


  const LikeDislikePost({Key? key, required this.currUserRef, required this.post, required this.postLikesManager, required this.currUserColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: currUserRef, postRef: post.postRef);
    Color activeColor = currUserColor!=null ? currUserColor! : colorScheme.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            () {
          if (postLikesManager.likeStatus == true) {
            return IconButton(
              iconSize: postIconSizeStateless,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(9),
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(ThickArrow.angle_up_icon, color: activeColor),
              onPressed: () {
                HapticFeedback.heavyImpact();
                postLikesManager.onUnLike();
                _posts.unLikePost(post);
              },
            );
          } else {
            return IconButton(
              iconSize: postIconSizeStateless,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(9),
              constraints: BoxConstraints(),
              icon: Icon(ThickArrow.angle_up_icon),
              onPressed: () {
                HapticFeedback.heavyImpact();
                postLikesManager.onLike();
                _posts.likePost(post, postLikesManager.likeCount + 1); // because postLikesManager.likeCount is behind
              },
            );
          }
        }(),
        GestureDetector(
          onTap: () {},
          child: Text(
            (postLikesManager.likeCount - postLikesManager.dislikeCount).toString(),
            style: Theme
                .of(context)
                .textTheme
                .subtitle1?.copyWith(fontSize: 0.8 * postIconSizeStateless),
          ),
        ),
            () {
          if (postLikesManager.dislikeStatus == true) {
            return IconButton(
              iconSize: postIconSizeStateless,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(9),
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(ThickArrow.angle_down_icon, color: activeColor),
              onPressed: () {
                HapticFeedback.heavyImpact();
                postLikesManager.onUnDislike();
                _posts.unDislikePost();
              },
            );
          } else {
            return IconButton(
              iconSize: postIconSizeStateless,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(9),
              constraints: BoxConstraints(),
              icon: Icon(ThickArrow.angle_down_icon),
              onPressed: () {
                HapticFeedback.heavyImpact();
                postLikesManager.onDislike();
                _posts.dislikePost();
              },
            );
          }
        }(),
      ],
    );
  }
}


class LikeDislikePostStateful extends StatefulWidget {
  final DocumentReference currUserRef;
  final Post post;
  final PostLikesManager postLikesManager;
  final Color? currUserColor;

  const LikeDislikePostStateful(
      {Key? key, required this.currUserRef, required this.post, required this.postLikesManager, required this.currUserColor})
      : super(key: key);

  @override
  _LikeDislikePostStatefulState createState() => _LikeDislikePostStatefulState();
}

class _LikeDislikePostStatefulState extends State<LikeDislikePostStateful> {
  bool likeStatus = false;
  bool dislikeStatus = false;
  int likeCount = 0;
  int dislikeCount = 0;

  @override
  void initState() {
    if (mounted) {
      setState(() {
        likeStatus = widget.postLikesManager.likeStatus;
        dislikeStatus = widget.postLikesManager.dislikeStatus;
        likeCount = widget.postLikesManager.likeCount;
        dislikeCount = widget.postLikesManager.dislikeCount;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.currUserRef, postRef: widget.post.postRef);

    Color activeColor = widget.currUserColor!=null ? widget.currUserColor! : colorScheme.secondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            () {
          if (likeStatus == true) {
            return IconButton(
              iconSize: postIconSizeStateful,
              splashColor: Colors.transparent,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(ThickArrow.angle_up_icon, color: activeColor),
              onPressed: () {
                HapticFeedback.heavyImpact();
                widget.postLikesManager.onUnLike();
                if (mounted) {
                  setState(() {
                    likeCount -= 1;
                    likeStatus = false;
                  });
                }
                _posts.unLikePost(widget.post);
              },
            );
          } else {
            return IconButton(
              iconSize: postIconSizeStateful,
              splashColor: Colors.transparent,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(ThickArrow.angle_up_icon),
              onPressed: () {
                HapticFeedback.heavyImpact();
                widget.postLikesManager.onLike();
                if (mounted) {
                  setState(() {
                    likeCount += 1;
                    if (dislikeStatus == true) dislikeCount -= 1;
                    likeStatus = true;
                    dislikeStatus = false;
                  });
                }
                _posts.likePost(widget.post, likeCount);
              },
            );
          }
        }(),
        SizedBox(width: 10),
        Text(
          (likeCount - dislikeCount).toString(),
          style: Theme
              .of(context)
              .textTheme
              .subtitle1?.copyWith(fontSize: 0.8 * postIconSizeStateful),
        ),
        SizedBox(width: 10),
            () {
          if (dislikeStatus == true) {
            return IconButton(
              iconSize: postIconSizeStateful,
              splashColor: Colors.transparent,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(ThickArrow.angle_down_icon, color: activeColor),
              onPressed: () {
                HapticFeedback.heavyImpact();
                widget.postLikesManager.onUnDislike();
                if (mounted) {
                  setState(() {
                    dislikeCount -= 1;
                    dislikeStatus = false;
                  });
                }
                _posts.unDislikePost();
              },
            );
          } else {
            return IconButton(
              iconSize: postIconSizeStateful,
              splashColor: Colors.transparent,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(ThickArrow.angle_down_icon),
              onPressed: () {
                HapticFeedback.heavyImpact();
                widget.postLikesManager.onDislike();
                if (mounted) {
                  setState(() {
                    dislikeCount += 1;
                    if (likeStatus == true) likeCount -= 1;
                    dislikeStatus = true;
                    likeStatus = false;
                  });
                }
                _posts.dislikePost();
              },
            );
          }
        }(),

      ],
    );
  }
}