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

  const PostNotificationCard(
      {Key? key,
      required this.post,
      required this.currUserRef,
      required this.groupImage,
      required this.groupName,
      required this.groupColor})
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
                            Text(post.title,
                                style: ThemeText.titleRegular(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2),
                          ]),
                          SizedBox(height: 12),
                          Row(
                            //Icon Row
                            children: [
                              newResponseIcon(),
                              Spacer(),
                              Text((post.likes.length - post.dislikes.length).toString() + " Likes",
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
                )
            )
            ));
  }
}
/*

Container(
              padding: const EdgeInsets.fromLTRB(7.0,12.0,10.0,5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10),
                  Flexible(
                    //Otherwise horizontal renderflew of row
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GroupTag( groupColor: groupColor != null ? HexColor(groupColor!) : null, groupImage:groupImage, groupName: groupName, fontSize:12),
                            Spacer(),
                            Icon(Icons.more_horiz),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          //TODO: Need to figure out ways to ref
                          widget.post.title,
                          style: ThemeText.titleRegular(), overflow: TextOverflow.ellipsis, // default is .clip
                          maxLines: 3
                        ),
                        //SizedBox(height: 10),
                        Row( //Icon Row
                          children: [
                            SizedBox(width:10),
                            Text(
                              (widget.post.numComments + widget.post.numReplies).toString()
                              + " Comments",
                              style: ThemeText.regularSmall(fontSize: 15.0, color: ThemeColor.mediumGrey),
                            ),
                            Spacer(),
                            LikeDislikePost(
                                currUserRef: widget.currUserRef,
                                postRef: widget.post.postRef,
                                likes: widget.post.likes,
                                dislikes: widget.post.dislikes),
                          ],
                        )
                      ], //Column Children ARRAY
                    ),
                  )
                ],
              ))
 */
