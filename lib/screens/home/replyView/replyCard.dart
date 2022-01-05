import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/replyView/likeDislikeReply.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/services/user_data_database.dart';

class ReplyCard extends StatefulWidget {
  final Reply reply;
  final DocumentReference currUserRef;

  ReplyCard(
      {Key? key,
      required this.reply,
      required this.currUserRef})
      : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.reply.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          liked = true;
        });
      }
    } else if (widget.reply.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          disliked = true;
        });
      }
    }
    // find username for userId
    // _userInfoDatabaseService.userId = widget.userId;
    getUsername();
    super.initState();
  }

  void getUsername() async {
    if (widget.reply.creatorRef != null) {
      UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
      final UserData? fetchUsername = await _userInfoDatabaseService.getUserData(userRef: widget.reply.creatorRef);
      if (mounted) {
        setState(() {
          username = fetchUsername != null ? fetchUsername.displayedName : '<Failed to retrieve user name>';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          username = '[Removed]';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.reply.commentRef),
      child: Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
          title: Text(widget.reply.text),
          subtitle: Text(username),
          trailing: LikeDislikeReply(
              replyRef: widget.reply.replyRef,
              currUserRef: widget.currUserRef,
              likes: widget.reply.likes,
              dislikes: widget.reply.dislikes),
        ),
        widget.reply.media != null
            ? Semantics(
                label: 'new_profile_pic_picked_image',
                child: Image.network(
                    widget.reply.media!) // kIsWeb ? Image.network(widget.image!) : Image.file(File(widget.image!)),
                )
            : Container(),
      ])),
      onDismissed: (DismissDirection direction) {
        if (mounted) {
          setState(() {
            RepliesDatabaseService _replies = RepliesDatabaseService(currUserRef: widget.currUserRef);
            _replies.deleteReply(
                replyRef: widget.reply.replyRef,
                commentRef: widget.reply.commentRef,
                postRef: widget.reply.postRef,
                media: widget.reply.media);
          });
        }
      },
    );
  }
}
