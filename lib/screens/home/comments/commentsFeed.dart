import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/comments/commentCard.dart';
import 'package:hs_connect/screens/home/comments/commentReplyForm.dart';
import 'package:hs_connect/screens/home/postView/postTitleCard.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class CommentsFeed extends StatefulWidget {
  final Post post;
  final Group group;

  CommentsFeed({Key? key, required this.post, required this.group}) : super(key: key);

  @override
  _CommentsFeedState createState() => _CommentsFeedState();
}

class _CommentsFeedState extends State<CommentsFeed> {

  bool isReply=false;
  DocumentReference? commentRef;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;


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
                return a.createdAt.compareTo(b.createdAt);
              });

              return ListView.builder(
                itemCount: comments.length + 3,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return PostTitleCard(
                      post: widget.post,
                      group: widget.group,
                      currUserRef: userData.userRef,
                    );
                  } else if (index == 1) {
                    return Divider(thickness: 3 * hp, color: colorScheme.background, height: 10 * hp);
                  } else if (index == comments.length+2){
                    return SizedBox(height: 70*hp);
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
            child: Container(
            padding: EdgeInsets.only(top: 1.5 * hp),
            decoration: BoxDecoration(
              gradient: Gradients.blueRed(),
            ),
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(10 * wp, 10 * hp, 10 * wp, 10 * hp),
                color: colorScheme.background,
              child: CommentReplyForm(
                currUserRef: userData.userRef,
                switchFormBool: switchFormBool,
                commentReference: commentRef,
                isReply: isReply,
                post: widget.post)
              ),
            )
              ,
          ),
      ],
    );
  }
}
