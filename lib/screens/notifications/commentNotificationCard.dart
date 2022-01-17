import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';

import 'newResponseIcon.dart';

class CommentNotificationCard extends StatelessWidget {
  final Comment comment;
  final Post? originPost;
  final Image? groupImage;
  final String groupName;
  final String? groupColor;
  final DocumentReference currUserRef;

  const CommentNotificationCard(
      {Key? key,
      required this.comment,
      required this.originPost,
      required this.currUserRef,
      required this.groupImage,
      required this.groupName,
      required this.groupColor})
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
            margin: EdgeInsets.fromLTRB(2.5, 5, 2.5, 2.5),
            elevation: 0,
            color: ThemeColor.white,
            child: Container(
                padding: const EdgeInsets.fromLTRB(15,15,15,15),
                child: Row(
                  children: [
                    Flexible(
                      //Otherwise horizontal renderflew of row
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GroupTag(
                                  groupImage: groupImage,
                                  groupName: groupName,
                                  fontSize: 13,
                                  groupColor: groupColor != null ? HexColor(groupColor!) : ThemeColor.darkGrey),
                              Spacer(),
                              Icon(Icons.more_horiz),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(children: [
                            Text(comment.text,
                                style: ThemeText.titleRegular(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2),
                          ]),
                          SizedBox(height: 5),
                          originPost != null
                              ? Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                      side: BorderSide(color: ThemeColor.lightGrey, width: 2)),
                                  elevation: 0,
                                  margin: EdgeInsets.fromLTRB(13, 5, 5, 5),
                                  child: Container(
                                    padding: EdgeInsets.all(6.5),
                                    child: Text("Responding to post: " + originPost!.title,
                                        style: ThemeText.titleRegular(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1),
                                  ),
                                )
                              : Container(),
                          originPost != null ? SizedBox(height: 8) : Container(),
                          Row(
                            //Icon Row
                            children: [
                              newResponseIcon(),
                              Spacer(),
                              Text((comment.likes.length - comment.dislikes.length).toString() + " Likes",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: "Inter",
                                      color: ThemeColor.black,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        ], //Column Children ARRAY
                      ),
                    )
                  ],
                )))

        /*Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            margin: EdgeInsets.fromLTRB(2.5, 5, 2.5, 2.5),
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
                      newResponseIcon(),
                      Spacer(),
                      Text((comment.likes.length-comment.dislikes.length).toString() + " Likes", style: ThemeText.regularSmall()),
                      SizedBox(width: 10.0),
                    ])
                  ]))
                ])))*/
        );
  }
}
