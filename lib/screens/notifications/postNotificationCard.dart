import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/screens/notifications/newResponseIcon.dart';
import 'package:hs_connect/shared/constants.dart';

class PostNotificationCard extends StatelessWidget {
  final Post post;
  final Widget groupCircle;
  final DocumentReference currUserRef;

  const PostNotificationCard({Key? key, required this.post, required this.groupCircle, required this.currUserRef})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new PostPage(
                        postRef: post.postRef,
                        currUserRef: currUserRef,
                      )));
        },
        child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            margin: EdgeInsets.fromLTRB(2.5, 5.0, 2.5, 2.5),
            elevation: 0.0,
            color: ThemeColor.white,
            child: Container(
                padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                child: Row(children: <Widget>[
                  SizedBox(width: 5.0),
                  Column(children: <Widget>[
                    //SizedBox(height: 10.0),
                    groupCircle,
                    SizedBox(height: 20.0),
                  ]),
                  Flexible(
                    child: Column(children: <Widget>[
                      Row(children: <Widget>[
                        SizedBox(width: 10.0),
                        SizedBox(
                            width: 250.0,
                            child: Text(post.title,
                                style: ThemeText.titleRegular(fontSize: 15.0),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2))
                      ]),
                      SizedBox(height: 10.0),
                      Row(children: <Widget>[
                        SizedBox(width: 5.0),
                        newResponseIcon(),
                        Spacer(),
                        Text((post.likes.length - post.dislikes.length).toString() + " Likes",
                            style: ThemeText.regularSmall()),
                        SizedBox(width: 10.0),
                      ])
                    ]),
                  )
                ]))));
  }
}
