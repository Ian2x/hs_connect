import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/screens/notifications/newResponseIcon.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';

class PostNotificationCard extends StatelessWidget {
  final Post post;
  final Image? groupImage;
  final String groupName;
  final String? groupColor;
  final DocumentReference currUserRef;

  const PostNotificationCard({Key? key, required this.post, required this.currUserRef, required this.groupImage, required this.groupName, required this.groupColor})
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
            margin: EdgeInsets.fromLTRB(2.5, 5, 2.5, 2.5),
            elevation: 0,
            color: ThemeColor.white,
            child: Stack(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Row(
                    children: <Widget>[
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height:10),
                            GroupTag(groupImage: groupImage, groupName: groupName, groupColor: groupColor != null ? HexColor(groupColor!) : null, fontSize: 14,),
                            SizedBox(height: 10),
                            SizedBox(
                                width: (MediaQuery.of(context).size.width) * 0.65,
                                child: Text(post.title,
                                    style: ThemeText.titleRegular(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2)),
                            SizedBox(height: 10),
                            newResponseIcon(),
                          ]
                      ),
                      Spacer()
                    ]
                  )
                )
                /*Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        SizedBox(height: 10),
                        SizedBox(
                            width: (MediaQuery.of(context).size.width) * 0.65,
                            child: Text(post.title,
                                style: ThemeText.titleRegular(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2)),
                        SizedBox(height: 10),
                        newResponseIcon(),
                      ]),
                      Spacer(),
                      Container(
                        width: 30,
                        height: 50,
                        child: Column(
                            //mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text("..."),
                              Spacer(),
                              Text((post.likes.length - post.dislikes.length).toString() + " Likes",
                                  style: TextStyle(fontSize: 14, fontFamily: "Inter", color: ThemeColor.black, fontWeight: FontWeight.bold)),
                            ]),
                      )
                    ]))*/
              ],
            )));
  }
}

/*
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
 */
