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
  final Post postInfo;
  final DocumentReference groupRef;

  const CommentsFeed({Key? key, required this.postInfo, required this.groupRef}) : super(key: key);

  @override
  _CommentsFeedState createState() => _CommentsFeedState();
}

class _CommentsFeedState extends State<CommentsFeed> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    CommentsDatabaseService _comments = CommentsDatabaseService(postRef: widget.postInfo.postRef);

    return StreamBuilder(
      stream: _comments.postComments,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        } else {
          final comments = (snapshot.data as List<Comment?>).map((comment) => comment!).toList();

          return ListView.builder(
            itemCount: comments.length + 3,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return RoundedPostCard(
                  postInfo: widget.postInfo,
                  userRef: userData.userRef,
                  groupRef: widget.groupRef,
                );
              } else if (index == 1) {
                return Divider(thickness: 3, color: HexColor('E9EDF0'), height: 20);
              } else if (index == comments.length + 2) {
                return CommentForm(postRef: widget.postInfo.postRef, groupRef: widget.groupRef);
              } else {
                return CommentCard(
                  commentRef: comments[index - 2].commentRef,
                  postRef: comments[index - 2].postRef,
                  userRef: comments[index - 2].creatorRef,
                  groupRef: comments[index - 2].groupRef,
                  text: comments[index - 2].text,
                  media: comments[index - 2].media,
                  createdAt: comments[index - 2].createdAt,
                  likes: comments[index - 2].likes,
                  dislikes: comments[index - 2].dislikes,
                  currUserRef: userData.userRef,
                  reportsRefs: comments[index - 2].reportsRefs,
                );
              }
            },
          );
        }
      },
    );
  }
}
