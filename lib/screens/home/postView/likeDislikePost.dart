import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/shared/widgets/arrows_icons.dart';

const double postIconSizeStateless = 18;
const double postIconSizeStateful = 22;
const EdgeInsets postIconPadding = EdgeInsets.zero;

class LikeDislikePost extends StatelessWidget {
  final DocumentReference currUserRef;
  final Post post;
  final PostLikesManager postLikesManager;


  const LikeDislikePost({Key? key, required this.currUserRef, required this.post, required this.postLikesManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider
        .of<HeightPixel>(context)
        .value;
    final wp = Provider
        .of<WidthPixel>(context)
        .value;
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: currUserRef, postRef: post.postRef);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            () {
          if (postLikesManager.likeStatus == true) {
            return IconButton(
              iconSize: postIconSizeStateless * hp,
              splashColor: Colors.transparent,
              padding: postIconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Arrows.up_open_big, color: colorScheme.secondary),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _posts.unLikePost(post);
                postLikesManager.onUnLike();
              },
            );
          } else {
            return IconButton(
              iconSize: postIconSizeStateless * hp,
              splashColor: Colors.transparent,
              padding: postIconPadding,
              constraints: BoxConstraints(),
              icon: Icon(Arrows.up_open_big),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _posts.likePost(post, postLikesManager.likeCount);
                postLikesManager.onLike();
              },
            );
          }
        }(),
        SizedBox(width: 8 * wp),
        Text(
          (postLikesManager.likeCount - postLikesManager.dislikeCount).toString(),
          style: Theme
              .of(context)
              .textTheme
              .subtitle1?.copyWith(fontSize: postIconSizeStateless * hp),
        ),
        SizedBox(width: 8 * wp),
            () {
          if (postLikesManager.dislikeStatus == true) {
            return IconButton(
              iconSize: postIconSizeStateless * hp,
              splashColor: Colors.transparent,
              padding: postIconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Arrows.down_open_big, color: colorScheme.onBackground),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _posts.unDislikePost();
                postLikesManager.onUnDislike();
              },
            );
          } else {
            return IconButton(
              iconSize: postIconSizeStateless * hp,
              splashColor: Colors.transparent,
              padding: postIconPadding,
              constraints: BoxConstraints(),
              icon: Icon(Arrows.down_open_big),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _posts.dislikePost();
                postLikesManager.onDislike();
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

  const LikeDislikePostStateful(
      {Key? key, required this.currUserRef, required this.post, required this.postLikesManager})
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
    final hp = Provider
        .of<HeightPixel>(context)
        .value;
    final wp = Provider
        .of<WidthPixel>(context)
        .value;
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.currUserRef, postRef: widget.post.postRef);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            () {
          if (likeStatus == true) {
            return IconButton(
              iconSize: postIconSizeStateful * hp,
              splashColor: Colors.transparent,
              padding: postIconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Arrows.up_open_big, color: colorScheme.secondary),
              onPressed: () {
                _posts.unLikePost(widget.post);
                widget.postLikesManager.onUnLike();
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
              iconSize: postIconSizeStateful * hp,
              splashColor: Colors.transparent,
              padding: postIconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(Arrows.up_open_big),
              onPressed: () {
                _posts.likePost(widget.post, likeCount);
                widget.postLikesManager.onLike();
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
        SizedBox(width: 10 * wp),
        Text(
          (likeCount - dislikeCount).toString(),
          style: Theme
              .of(context)
              .textTheme
              .subtitle1?.copyWith(fontSize: 0.75 * postIconSizeStateful * hp),
        ),
        SizedBox(width: 10 * wp),

            () {
          if (dislikeStatus == true) {
            return IconButton(
              iconSize: postIconSizeStateful * hp,
              splashColor: Colors.transparent,
              padding: postIconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Arrows.down_open_big, color: colorScheme.secondary),
              onPressed: () {
                _posts.unDislikePost();
                widget.postLikesManager.onUnDislike();
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
              iconSize: postIconSizeStateful * hp,
              splashColor: Colors.transparent,
              padding: postIconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(Arrows.down_open_big),
              onPressed: () {
                _posts.dislikePost();
                widget.postLikesManager.onDislike();
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