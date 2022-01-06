import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/groupView/groupPage.dart';
import 'package:hs_connect/screens/home/postFeed/specificGroupFeed.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/noAnimationMaterialPageRoute.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/screens/home/commentView/commentForm.dart';

class RoundedPostCard extends StatefulWidget {
  final Post post;
  final DocumentReference currUserRef;

  RoundedPostCard({
    Key? key,
    required this.post,
    required this.currUserRef,
  }) : super(key: key);

  @override
  _RoundedPostCardState createState() => _RoundedPostCardState();
}

class _RoundedPostCardState extends State<RoundedPostCard> {
  
  //final userData = Provider.of<UserData?>(context);

  bool liked = false;
  bool disliked = false;
  String userDomain = '<Loading user domain...>';
  String username = '<Loading user name...>';
  String groupName = '<Loading group name...>';
  Image groupImage = Image(image: AssetImage('assets/masonic-G.png'), height: 20, width: 20);

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
        Navigator.pushReplacement(
          context,
          NoAnimationMaterialPageRoute(builder: (context) =>
              GroupPage(currUserRef: widget.currUserRef,groupRef: widget.post.groupRef,)),
        );
      },
      child: Card(
          margin: EdgeInsets.fromLTRB(6.0, 1.0, 6.0, 0.0),
          elevation: 0.0,
          child: Container(
              decoration: ShapeDecoration(
                color: HexColor('FFFFFF'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    side: BorderSide(
                      color: HexColor("E9EDF0"),
                      width: 3.0,
                    )),
              ),
              padding: const EdgeInsets.all(8.0),
              //color: HexColor("FFFFFF"),
              alignment: Alignment(-1.0, -1.0), //Aligned to Top Left
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.account_circle, size: 40, color: Colors.black),
                      //Spacer(),
                    ],
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    //Otherwise horizontal renderflew of row
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username + " • " + userDomain,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15.0,
                            color: HexColor("#222426"),
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          groupName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            color: HexColor("#222426"),
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          //TODO: Need to figure out ways to ref
                          widget.post.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            color: HexColor("#222426"),
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.post.text != null ? widget.post.text! : '',
                          overflow: TextOverflow.ellipsis, // default is .clip
                          maxLines: 3,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            color: HexColor("#2F3031"),
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              //widget.postInfo.createdAt.toString()
                              convertTime(widget.post.createdAt.toDate()),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                                color: HexColor("#2F3031"),
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.mode_comment_outlined, color: Colors.black, size: 15.0),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CommentForm(postRef: widget.post.postRef, groupRef: widget.post.groupRef)),
                                );
                              },
                            ),
                            Text(
                              (widget.post.commentsRefs.length + widget.post.repliesRefs.length).toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                                color: HexColor("#2F3031"),
                                fontFamily: 'Segoe UI',
                              ),
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
