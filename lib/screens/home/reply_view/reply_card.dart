import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/reply_view/like_dislike_reply.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/services/user_data_database.dart';

class ReplyCard extends StatefulWidget {
  final DocumentReference replyRef;
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference? userRef;
  final String text;
  final String? media;
  final Timestamp createdAt;
  List<DocumentReference> likes;
  List<DocumentReference> dislikes;
  final DocumentReference currUserRef;

  ReplyCard(
      {Key? key,
      required this.replyRef,
      required this.commentRef,
      required this.postRef,
      required this.userRef,
      required this.text,
      required this.media,
      required this.createdAt,
      required this.likes,
      required this.dislikes,
      required this.currUserRef})
      : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService();

  RepliesDatabaseService _replies = RepliesDatabaseService();

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          liked = true;
        });
      }
    } else if (widget.likes.contains(widget.currUserRef)) {
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
    if (widget.userRef != null) {
      final UserData? fetchUsername = await _userInfoDatabaseService.getUserData(userRef: widget.userRef!);
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
      key: ValueKey(widget.commentRef),
      child: Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
          title: Text(widget.text),
          subtitle: Text(username),
          trailing: LikeDislikeReply(
              replyRef: widget.replyRef,
              currUserRef: widget.currUserRef,
              likes: widget.likes,
              dislikes: widget.dislikes),
        ),
            widget.media!=null ? Semantics(
                label: 'new_profile_pic_picked_image',
                child: Image.network(widget.media!) // kIsWeb ? Image.network(widget.image!) : Image.file(File(widget.image!)),
            ) : Container(),
      ])),
      onDismissed: (DismissDirection direction) {
        if (mounted) {
          setState(() {
            _replies.deleteReply(replyRef: widget.replyRef, commentRef: widget.commentRef, postRef: widget.postRef, userRef: widget.currUserRef, media: widget.media);
          });
        }
      },
    );
  }
}
