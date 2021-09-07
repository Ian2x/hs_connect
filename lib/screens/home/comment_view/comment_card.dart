import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/comment_view/comment_form.dart';
import 'package:hs_connect/screens/home/comment_view/like_dislike_comment.dart';
import 'package:hs_connect/screens/home/post_view/delete_post.dart';
import 'package:hs_connect/screens/home/post_view/like_dislike_post.dart';
import 'package:hs_connect/screens/home/post_view/post_page.dart';
import 'package:hs_connect/screens/home/reply_feed/reply_feed.dart';
import 'package:hs_connect/screens/home/reply_view/reply_form.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';

class CommentCard extends StatefulWidget {
  final String commentId;
  final String postId;
  final String userId;
  final String text;
  final String? image;
  final String createdAt;
  List<String> likes;
  List<String> dislikes;
  final String currUserId;

  CommentCard(
      {Key? key,
      required this.commentId,
      required this.postId,
      required this.userId,
      required this.text,
      required this.image,
      required this.createdAt,
      required this.likes,
      required this.dislikes,
      required this.currUserId})
      : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  UserInfoDatabaseService _userInfoDatabaseService = UserInfoDatabaseService();

  CommentsDatabaseService _comments = CommentsDatabaseService();

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.likes.contains(widget.currUserId)) {
      setState(() {
        liked = true;
      });
    } else if (widget.likes.contains(widget.currUserId)) {
      setState(() {
        disliked = true;
      });
    }
    // find username for userId
    // _userInfoDatabaseService.userId = widget.userId;
    getUsername();
    super.initState();
  }

  void getUsername() async {
    final UserData? fetchUsername = await _userInfoDatabaseService.getUserData(userId: widget.userId);
    setState(() {
      username = fetchUsername != null ? fetchUsername.displayedName : '<Failed to retrieve user name>';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.commentId),
      child: Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
          title: Text(widget.text),
          subtitle: Text(username),
          trailing: LikeDislikeComment(
              commentId: widget.commentId,
              currUserId: widget.currUserId,
              likes: widget.likes,
              dislikes: widget.dislikes),
        ),
        RepliesFeed(commentId: widget.commentId),
      ])),
      onDismissed: (DismissDirection direction) {
        setState(() {
          _comments.deleteComment(commentId: widget.commentId, userId: widget.currUserId);
        });
      },
    );
  }
}
