import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/comment_view/comment_form.dart';
import 'package:hs_connect/screens/home/post_view/delete_post.dart';
import 'package:hs_connect/screens/home/post_view/post_page.dart';
import 'package:hs_connect/screens/home/reply_view/like_dislike_reply.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';

class ReplyCard extends StatefulWidget {
  final String replyId;
  final String commentId;
  final String userId;
  final String text;
  final String? image;
  final String createdAt;
  List<String> likes;
  List<String> dislikes;
  final String currUserId;

  ReplyCard(
      {Key? key,
        required this.replyId,
        required this.commentId,
        required this.userId,
        required this.text,
        required this.image,
        required this.createdAt,
        required this.likes,
        required this.dislikes,
        required this.currUserId})
      : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  UserInfoDatabaseService _userInfoDatabaseService = UserInfoDatabaseService();

  RepliesDatabaseService _replies = RepliesDatabaseService();

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
              trailing: LikeDislikeReply(replyId: widget.replyId, currUserId: widget.currUserId, likes: widget.likes, dislikes: widget.dislikes),
            ),
          ])),
      onDismissed: (DismissDirection direction) {
        setState(() {
          _replies.deleteReply(replyId: widget.replyId, userId: widget.currUserId);
        });
      },
    );
  }
}
