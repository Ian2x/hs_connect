import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final DocumentReference currUserRef;

  PostCard({Key? key, required this.post, required this.currUserRef}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  bool liked = false;
  bool disliked = false;
  String userDomain = '';
  String username = '';
  String groupName = '';
  bool inDomain = false;

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.post.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          liked = true;
        });
      }
    } else if (widget.post.dislikes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          disliked = true;
        });
      }
    }
    // find username for userId
    getUserData();
    getGroupName();
    super.initState();
  }

  void getUserData() async {
    UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    final UserData? fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.post.creatorRef);
    if (mounted) {
      setState(() {
        username = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
        userDomain = fetchUserData != null ? fetchUserData.domain : '<Failed to retrieve user domain>';
      });
    }
  }

  void getGroupName() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroup = await _groups.groupFromRef(widget.post.groupRef);
    if (mounted) {
      setState(() {
        if (fetchGroup!=null) {
          groupName = fetchGroup.name;
          if (fetchGroup.accessRestriction== AccessRestriction(restriction: groupName, restrictionType: AccessRestrictionType.domain)) {
            inDomain=true;
          }
        } else {
          groupName = '<Failed to retrieve group name>';
        }
        groupName = fetchGroup != null ? fetchGroup.name : '<Failed to retrieve group name>';

      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostPage(postRef: widget.post.postRef, currUserRef: widget.currUserRef,)),
        );
      },
      child: Card(
          //if border then ShapeDecoration
          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10.0)),
          margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
          //color: HexColor("#292929"),
          elevation: 0.0,
          child: Container(
              padding: const EdgeInsets.fromLTRB(7.0,12.0,5.0,5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10),
                  Flexible(
                    //Otherwise horizontal renderflew of row
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'in ',
                            style: ThemeText.regularSmall(),
                            children: <TextSpan>[
                              TextSpan(text: groupName,style: ThemeText.groupBold(color: translucentColorFromString(groupName))),
                              TextSpan(text: inDomain ? '' : ' from ', style: ThemeText.regularSmall()),
                              TextSpan(text: inDomain ? '' : userDomain, style: ThemeText.groupBold(color: translucentColorFromString(userDomain))),
                              TextSpan(text: ' • ' + convertTime(widget.post.createdAt.toDate()), style: ThemeText.regularSmall()),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          //TODO: Need to figure out ways to ref
                          widget.post.title,
                          style: ThemeText.titleRegular(), overflow: TextOverflow.ellipsis, // default is .clip
                          maxLines: 3
                        ),
                        //SizedBox(height: 10),
                        if (widget.post.text != null || widget.post.text == "") Text(
                            widget.post.text!,
                            maxLines:2,
                            style:ThemeText.regularSmall(),
                          overflow: TextOverflow.ellipsis,
                          ) else SizedBox(height:1),
                        Row( //Icon Row
                          children: [
                            SizedBox(width:10),
                            Icon(
                              Icons.chat_bubble_rounded,
                              color: ThemeColor.secondaryBlue,
                              size: 15.0,
                            ),
                            SizedBox(width:5),
                            Text(
                              (widget.post.numComments + widget.post.numReplies).toString(),
                              style: ThemeText.regularSmall(fontSize: 15.0),
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
              ))),
    );
  }
}
