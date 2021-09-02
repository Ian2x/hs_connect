import 'package:flutter/material.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/posts_database.dart';

class LikeDislikeComment extends StatefulWidget {
  final String currUserId;
  final String commentId;
  final List<String> likes;
  final List<String> dislikes;

  const LikeDislikeComment(
      {Key? key, required this.currUserId, required this.commentId, required this.likes, required this.dislikes})
      : super(key: key);

  @override
  _LikeDislikeCommentState createState() => _LikeDislikeCommentState();
}

class _LikeDislikeCommentState extends State<LikeDislikeComment> {
  CommentsDatabaseService _comments = CommentsDatabaseService();

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
      dislikeCount = widget.likes.length;
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
                _comments.unLikeComment(commentId: widget.commentId, userId: widget.currUserId);
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
                _comments.likeComment(commentId: widget.commentId, userId: widget.currUserId);
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
                _comments.unDislikeComment(commentId: widget.commentId, userId: widget.currUserId);
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
                _comments.dislikeComment(commentId: widget.commentId, userId: widget.currUserId);
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

/*
        if (likeStatus == true) {
      IconButton(
        iconSize: 20.0,
        icon: Icon(Icons.thumb_up),
        onPressed: () {
          _comments.unLikeComment(commentId: widget.commentId, userId: widget.currUserId);
          setState(() {
            likeStatus = false;
          });
        },
      );
    } else {
    IconButton(
    iconSize: 20.0,
    icon: Icon(Icons.thumb_up_outlined),
    onPressed: () {
    _comments.likeComment(commentId: widget.commentId, userId: widget.currUserId);
    setState(() {
    likeStatus = true;
    });
    },
    );
    }

 */
      ],
    );

    if (likeStatus == true) {
      return IconButton(
        iconSize: 20.0,
        icon: Icon(Icons.thumb_up),
        onPressed: () {
          _comments.unLikeComment(commentId: widget.commentId, userId: widget.currUserId);
          setState(() {
            likeStatus = false;
          });
        },
      );
    } else {
      return IconButton(
        iconSize: 20.0,
        icon: Icon(Icons.thumb_up_outlined),
        onPressed: () {
          _comments.likeComment(commentId: widget.commentId, userId: widget.currUserId);
          setState(() {
            likeStatus = true;
          });
        },
      );
    }
  }
}

/*

import 'package:flutter/material.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/posts_database.dart';

class DislikeComment extends StatefulWidget {
  final String currUserId;
  final String commentId;
  final List<String> dislikes;

  const DislikeComment({Key? key, required this.currUserId, required this.commentId, required this.dislikes})
      : super(key: key);

  @override
  _DislikeCommentState createState() => _DislikeCommentState();
}

class _DislikeCommentState extends State<DislikeComment> {
  CommentsDatabaseService _comments = CommentsDatabaseService();

  bool dislikeStatus = false; // either liked, disliked, or empty

  @override
  void initState() {
    setState(() {
      setState(() {
        dislikeStatus = widget.dislikes.toList().contains(widget.currUserId);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (dislikeStatus == true) {
      return IconButton(
        iconSize: 20.0,
        icon: Icon(Icons.thumb_down),
        onPressed: () {
          _comments.unDislikeComment(commentId: widget.commentId, userId: widget.currUserId);
          setState(() {
            dislikeStatus = false;
          });
        },
      );
    } else {
      return IconButton(
        iconSize: 20.0,
        icon: Icon(Icons.thumb_down_outlined),
        onPressed: () {
          _comments.dislikeComment(commentId: widget.commentId, userId: widget.currUserId);
          setState(() {
            dislikeStatus = true;
          });
        },
      );
    }
  }
}


 */
