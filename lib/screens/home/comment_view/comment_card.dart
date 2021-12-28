import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/comment_view/like_dislike_comment.dart';
import 'package:hs_connect/screens/home/reply_feed/reply_feed.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:flutter/foundation.dart';


class CommentCard extends StatefulWidget {
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference? userRef;
  final String text;
  final String? media;
  final String createdAt;
  List<DocumentReference> likes;
  List<DocumentReference> dislikes;
  final DocumentReference currUserRef;
  final Report? reportedStatus;

  CommentCard(
      {Key? key,
      required this.commentRef,
      required this.postRef,
      required this.userRef,
      required this.text,
      required this.media,
      required this.createdAt,
      required this.likes,
      required this.dislikes,
      required this.currUserRef,
      required this.reportedStatus,
      })
      : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService();

  CommentsDatabaseService _comments = CommentsDatabaseService();

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.likes.contains(widget.currUserRef)) {
      setState(() {
        liked = true;
      });
    } else if (widget.likes.contains(widget.currUserRef)) {
      setState(() {
        disliked = true;
      });

    }
    getUsername();
    super.initState();
  }

  void getUsername() async {
    if (widget.userRef != null) {
      final UserData? fetchUsername = await _userDataDatabaseService.getUserData(userRef: widget.userRef!);
      setState(() {
        username = fetchUsername != null ? fetchUsername.displayedName : '<Failed to retrieve user name>';
      });
    } else {
      setState(() {
        username = '[Removed]';
      });
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
          trailing:
          LikeDislikeComment(
              commentRef: widget.commentRef,
              currUserRef: widget.currUserRef,
              likes: widget.likes,
              dislikes: widget.dislikes),

        ),
        widget.media!=null ? Semantics(
          label: 'new_profile_pic_picked_image',
          child: Image.network(widget.media!) // kIsWeb ? Image.network(widget.image!) : Image.file(File(widget.image!)),
        ) : Container(),
        RepliesFeed(commentRef: widget.commentRef, postRef: widget.postRef,),
      ])),
      onDismissed: (DismissDirection direction) {
        setState(() {
          _comments.deleteComment(commentRef: widget.commentRef, userRef: widget.currUserRef, media: widget.media, postRef: widget.postRef);
        });
      },
    );
  }
}
