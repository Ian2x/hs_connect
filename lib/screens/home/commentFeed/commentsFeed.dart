import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/commentView/commentCard.dart';
import 'package:hs_connect/screens/home/commentView/commentForm.dart';
import 'package:hs_connect/screens/home/postView/Widgets/RoundedPostCard.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class CommentsFeed extends StatefulWidget {
  final Post post;
  final DocumentReference groupRef;

  const CommentsFeed({Key? key, required this.post, required this.groupRef}) : super(key: key);

  @override
  _CommentsFeedState createState() => _CommentsFeedState();
}

class _CommentsFeedState extends State<CommentsFeed> {

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();
    CommentsDatabaseService _comments = CommentsDatabaseService(currUserRef: userData.userRef, postRef: widget.post.postRef, commentsRefs: widget.post.commentsRefs);

    return StreamBuilder(
      stream: _comments.postComments,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        } else {
          List<Comment?> commentss = (snapshot.data as List<Comment?>);
          commentss.removeWhere((value) => value == null);
          List<Comment> comments = commentss.map((item) => item!).toList();
          // sort by most recent
          comments.sort((a,b) {
            return b.createdAt.compareTo(a.createdAt);
          });

          return ListView.builder(
            itemCount: comments.length + 3,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return RoundedPostCard(
                  post: widget.post,
                  currUserRef: userData.userRef,
                );
              } else if (index == 1) {
                return Divider(thickness: 3, color: HexColor('E9EDF0'), height: 20);
              } else if (index == comments.length + 2) {
                return CommentForm(postRef: widget.post.postRef, groupRef: widget.groupRef);
              } else {
                return CommentCard(
                  comment: comments[index - 2],
                  currUserRef: userData.userRef,
                );
              }
            },
          );
        }
      },
    );
  }
}
