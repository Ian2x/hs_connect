import 'package:flutter/material.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/posts_database.dart';

class LikeDislikePost extends StatefulWidget {
  final String currUserId;
  final String postId;
  final List<String> likes;
  final List<String> dislikes;

  const LikeDislikePost(
      {Key? key, required this.currUserId, required this.postId, required this.likes, required this.dislikes})
      : super(key: key);

  @override
  _LikeDislikePostState createState() => _LikeDislikePostState();
}

class _LikeDislikePostState extends State<LikeDislikePost> {
  PostsDatabaseService _posts = PostsDatabaseService();

  bool likeStatus = false;
  bool dislikeStatus = false;
  int likeCount = 0;
  int dislikeCount = 0;

  @override
  void initState() {
    setState(() {
      likeStatus = widget.likes.contains(widget.currUserId);
      dislikeStatus = widget.dislikes.contains(widget.currUserId);
      likeCount = widget.likes.length;
      dislikeCount = widget.dislikes.length;
    });
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
                _posts.unLikePost(postId: widget.postId, userId: widget.currUserId);
                setState(() {
                  likeCount-=1;
                  likeStatus = false;
                });
              },
            );
          } else {
            return IconButton(
              iconSize: 20.0,
              icon: Icon(Icons.thumb_up_outlined),
              onPressed: () {
                _posts.likePost(postId: widget.postId, userId: widget.currUserId);
                setState(() {
                  likeCount+=1;
                  if(dislikeStatus==true) dislikeCount-=1;
                  likeStatus = true;
                  dislikeStatus = false;
                });
              },
            );
          }
        }(),
        Text((likeCount-dislikeCount).toString()),
            () {
          if (dislikeStatus == true) {
            return IconButton(
              iconSize: 20.0,
              icon: Icon(Icons.thumb_down),
              onPressed: () {
                _posts.unDislikePost(postId: widget.postId, userId: widget.currUserId);
                setState(() {
                  dislikeCount-=1;
                  dislikeStatus = false;
                });
              },
            );
          } else {
            return IconButton(
              iconSize: 20.0,
              icon: Icon(Icons.thumb_down_outlined),
              onPressed: () {
                _posts.dislikePost(postId: widget.postId, userId: widget.currUserId);
                setState(() {
                  dislikeCount+=1;
                  if(likeStatus==true) likeCount-=1;
                  dislikeStatus = true;
                  likeStatus = false;
                });
              },
            );
          }
        }()
      ],
    );
  }
}