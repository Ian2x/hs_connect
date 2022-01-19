import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/commentView/commentCard.dart';
import 'package:hs_connect/screens/home/commentView/commentReplyForm.dart';
import 'package:hs_connect/screens/home/postView/Widgets/postTitleCard.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class CommentsFeed extends StatefulWidget {
  final Post post;
  final DocumentReference groupRef;



  CommentsFeed({Key? key, required this.post, required this.groupRef}) : super(key: key);

  @override
  _CommentsFeedState createState() => _CommentsFeedState();
}

class _CommentsFeedState extends State<CommentsFeed> {

  bool isReply=false;
  DocumentReference? commentRef;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    switchFormBool(DocumentReference? passedRef){
      setState(() {
        isReply=!isReply;
        commentRef= passedRef;
      });
    }

    if (userData == null) return Loading();
    CommentsDatabaseService _comments = CommentsDatabaseService(currUserRef: userData.userRef, postRef: widget.post.postRef);

    return Stack(
      children: [
        StreamBuilder(
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
                itemCount: comments.length + 2,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return postTitleCard(
                      post: widget.post,
                      currUserRef: userData.userRef,
                    );
                  } else if (index == 1) {
                    return Divider(thickness: 3, color: ThemeColor.backgroundGrey, height: 20);
                  } else {
                    return CommentCard(
                      switchFormBool: switchFormBool,
                      comment: comments[index - 2],
                      currUserRef: userData.userRef,
                    );
                  }
                },
              );
            }
          },
        ),

          Positioned(
            bottom:0,
            right:0,
            child:
              CommentReplyForm(
                  switchFormBool: switchFormBool,
                  commentReference: commentRef,
                  isReply: isReply,
                  postRef: widget.post.postRef,
                  groupRef: widget.groupRef),
          ),
      ],
    );
  }
}
