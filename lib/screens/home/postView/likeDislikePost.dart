import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/shared/widgets/arrows_icons.dart';

const double iconSize = 32;

const EdgeInsets iconPadding = EdgeInsets.all(0);

class LikeDislikePost extends StatelessWidget {
  final DocumentReference currUserRef;
  final Post post;
  final PostLikesManager postLikesManager;


  const LikeDislikePost(
      {Key? key, required this.currUserRef, required this.post, required this.postLikesManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: currUserRef, postRef: post.postRef);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        () {
          if (postLikesManager.dislikeStatus == true) {
            return IconButton(
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Icons.keyboard_arrow_down_rounded),
              onPressed: () {
                _posts.unDislikePost();
                postLikesManager.onUnDislike();
              },
            );
          } else {
            return IconButton(
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(Icons.keyboard_arrow_down_rounded),
              onPressed: () {
                _posts.dislikePost();
                postLikesManager.onDislike();
              },
            );
          }
        }(),
        SizedBox(width: 5*wp),
        Text(
          (postLikesManager.likeCount - postLikesManager.dislikeCount).toString(),
          style: Theme.of(context).textTheme.subtitle1,
        ),
        SizedBox(width: 5*wp),
        () {
          if (postLikesManager.likeStatus == true) {
            return IconButton(
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Icons.keyboard_arrow_up_rounded, color: colorScheme.secondary),
              onPressed: () {
                _posts.unLikePost(post.creatorRef);
                postLikesManager.onUnLike();
              },
            );
          } else {
            return IconButton(
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(Icons.keyboard_arrow_up_rounded),
              onPressed: () {
                _posts.likePost(post.creatorRef, postLikesManager.likeCount);
                postLikesManager.onLike();
              },
            );
          }
        }()
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
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.currUserRef, postRef: widget.post.postRef);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            () {
          if (dislikeStatus == true) {
            return IconButton(
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Arrows.down_open_big, size:20),
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
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(Arrows.down_open_big, size:20),
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
        SizedBox(width: 5*wp),
        Text(
          (likeCount - dislikeCount).toString(),
          style: Theme.of(context).textTheme.subtitle1,
        ),
        SizedBox(width: 5*wp),
            () {
          if (likeStatus == true) {
            return IconButton(
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.secondary,
              icon: Icon(Arrows.down_open_big, color: colorScheme.secondary),
              onPressed: () {
                _posts.unLikePost(widget.post.creatorRef);
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
              iconSize: iconSize*hp,
              splashColor: Colors.transparent,
              padding: iconPadding,
              constraints: BoxConstraints(),
              color: colorScheme.primaryVariant,
              icon: Icon(Icons.keyboard_arrow_up_rounded),
              onPressed: () {
                _posts.likePost(widget.post.creatorRef, likeCount);
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
        }()
      ],
    );
  }
}