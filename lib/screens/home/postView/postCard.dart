import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postFeed/specificGroupFeed.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
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
  String userDomain = '<Loading user domain...>';
  String username = '<Loading user name...>';
  String groupName = '<Loading group name...>';

  ImageStorage _images = ImageStorage();

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
    final Group? fetchGroupName = await _groups.groupFromRef(widget.post.groupRef);
    if (mounted) {
      setState(() {
        groupName = fetchGroupName != null ? fetchGroupName.name : '<Failed to retrieve group name>';
      });
    }
  }

  void openSpecificGroupFeed() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SpecificGroupFeed(
                groupRef: widget.post.groupRef, currUserRef: widget.currUserRef,
              )),
    );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
          margin: EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 0.0),
          //color: HexColor("#292929"),
          elevation: 0.0,
          child: Container(
              padding: const EdgeInsets.all(8.0),
              color: HexColor("FFFFFF"),
              alignment: Alignment(-1.0, -1.0), //Aligned to Top Left
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
                              TextSpan(text: groupName,style: ThemeText.groupBold(translucentColorFromString(groupName))),
                              TextSpan(text: ' from ', style: ThemeText.regularSmall()),
                              TextSpan(text: userDomain, style: ThemeText.groupBold(translucentColorFromString(userDomain))),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          //TODO: Need to figure out ways to ref
                          widget.post.title,
                          style: ThemeText.titleRegular, overflow: TextOverflow.ellipsis, // default is .clip
                          maxLines:4
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.post.text != null ? widget.post.text! : '',
                          overflow: TextOverflow.ellipsis, // default is .clip
                          maxLines: 2,
                          style: ThemeText.regularSmall(),
                        ),
                        Row( //Icon Row
                          children: [
                            Text(
                              //widget.createdAt.toString()
                              convertTime(widget.post.createdAt.toDate()),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                                color: HexColor("#2F3031"),
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                            Spacer(),
                            Container(
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    ),
                              ),
                              //color: ThemeColor.secBlue,

                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_rounded,
                                    color: HexColor("FFFFFF"),
                                    size: 15.0,
                                  ),
                                  Text(
                                    (widget.post.commentsRefs.length + widget.post.repliesRefs.length).toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.0,
                                      color: HexColor("#FFFFF"),
                                      fontFamily: 'Segoe UI',
                                    ),
                                  ),
                                ]
                              )
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
