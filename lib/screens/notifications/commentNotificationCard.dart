import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/shared/constants.dart';

import 'numResponseIcon.dart';

class CommentNotificationCard extends StatelessWidget {
  final Comment comment;
  final Post? originPost;
  final Widget groupCircle;
  final DocumentReference currUserRef;

  const CommentNotificationCard(
      {Key? key, required this.comment, required this.originPost, required this.groupCircle, required this.currUserRef})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (originPost == null) {
      return Container();
    }
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new PostPage(
                        postRef: originPost!.postRef,
                        currUserRef: currUserRef,
                      )));
        },
        child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
            elevation: 0.0,
            color: ThemeColor.white,
            child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: Row(children: <Widget>[
                  SizedBox(width: 5.0),
                  Column(
                    children: <Widget>[
                      groupCircle,
                      SizedBox(height: 20),
                    ],
                  ),
                  Flexible(
                      child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      SizedBox(width: 10),
                      SizedBox(
                          width: 250,
                          child: Text(comment.text,
                              style: ThemeText.titleRegular(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2))
                    ]),
                    SizedBox(height: 10),
                    Row(children: <Widget>[
                      SizedBox(width: 5.0),
                      NumResponseIcon(numResponse: comment.newActivity == true ? -1 : comment.numReplies),
                      Spacer(),
                      Text((comment.likes.length-comment.dislikes.length).toString() + " Likes", style: ThemeText.regularSmall()),
                      SizedBox(width: 10.0),
                    ])
                  ]))
                ]))));
  }
}
