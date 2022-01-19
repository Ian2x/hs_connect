import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/commentView/likeDislikeComment.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';

class ReplyCard extends StatefulWidget {
  final Reply reply;
  final DocumentReference currUserRef;
  final bool isLast;

  ReplyCard(
      {Key? key,
      required this.isLast,
      required this.reply,
      required this.currUserRef})
      : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {

  bool liked = false;
  bool disliked = false;
  String username="";
  String groupName="";
  Color? groupColor;


  @override
  void initState() {
    super.initState();
    // initialize liked/disliked
    if (widget.reply.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          liked = true;
        });
      }
    } else if (widget.reply.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          disliked = true;
        });
      }
    }
    // find username for userId
    // _userInfoDatabaseService.userId = widget.userId;
    getUserData();
  }

  void getUserData() async {
    if (widget.reply.creatorRef != null) {
      UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
      final UserData? fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.reply.creatorRef);
      if (mounted) {
        setState(() {
          username = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
          groupColor = fetchUserData != null ? fetchUserData.domainColor :ThemeColor.black;
          groupName = fetchUserData != null ? fetchUserData.domain : '<Failed to retrieve user name>';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          username = '[Removed]';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top:-10,
          right:0,
          child:IconButton(icon: Icon(Icons.more_horiz),
            iconSize: 20,
            onPressed: (){},
          ),
        ),
        Container(
            padding: EdgeInsets.fromLTRB(20.0, 5, 0, 5.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(username + " • " + groupName,
                      style: ThemeText.groupBold(color: groupColor != null ? groupColor: ThemeColor.mediumGrey, fontSize: 13)),
                  SizedBox(height:10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /*Column(
                    children: [
                      Container(
                        width: imageSide,
                        height: imageSide,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: userImage!.image,
                              fit: BoxFit.fill,
                            )
                        ),
                      ),
                    ],
                  ),*/

                      Flexible(
                        fit:FlexFit.loose,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: (MediaQuery.of(context).size.width)*.85,
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(text: widget.reply.text,
                                        style: ThemeText.postViewText(color: ThemeColor.black, fontSize: 15, height: 1.5)),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  convertTime(widget.reply.createdAt.toDate()), style: ThemeText.groupBold(color:ThemeColor.mediumGrey, fontSize:14),
                                ),
                                Spacer(flex:1),
                                LikeDislikeComment(
                                    commentRef: widget.reply.commentRef,
                                    currUserRef: widget.currUserRef,
                                    likes: widget.reply.likes,
                                    dislikes: widget.reply.dislikes
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  widget.isLast !=false ?
                    Container() :
                    Divider(thickness: 3, color: ThemeColor.backgroundGrey, height: 40),
                ]
            )
        ),
      ],
    );
  }
}
