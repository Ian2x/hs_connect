import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/posts_database.dart';

class LikeDislikePost extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference postRef;
  final List<String> likes;
  final List<String> dislikes;

  const LikeDislikePost(
      {Key? key, required this.currUserRef, required this.postRef, required this.likes, required this.dislikes})
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
      likeStatus = widget.likes.contains(widget.currUserRef);
      dislikeStatus = widget.dislikes.contains(widget.currUserRef);
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
                _posts.unLikePost(postRef: widget.postRef, userRef: widget.currUserRef);
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
                _posts.likePost(postRef: widget.postRef, userRef: widget.currUserRef);
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
                _posts.unDislikePost(postRef: widget.postRef, userRef: widget.currUserRef);
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
                _posts.dislikePost(postRef: widget.postRef, userRef: widget.currUserRef);
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