import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/post_feeds/specific_group_feed.dart';
import 'package:hs_connect/screens/home/post_view/like_dislike_post.dart';
import 'package:hs_connect/screens/home/post_view/post_page.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';


class PostCard2 extends StatefulWidget {
  final DocumentReference postRef;
  final DocumentReference userRef;
  final DocumentReference groupRef;
  final String title;
  final String LCtitle;
  final String text;
  final String? media;
  final Timestamp createdAt;
  List<DocumentReference> likes;
  List<DocumentReference> dislikes;
  int numComments;
  final DocumentReference currUserRef;
  List<DocumentReference> reportedStatus;
  final List<String> tags;

  PostCard2(
      {Key? key,
        required this.postRef,
        required this.userRef,
        required this.groupRef,
        required this.title,
        required this.LCtitle,
        required this.text,
        required this.media,
        required this.createdAt,
        required this.likes,
        required this.dislikes,
        required this.numComments,
        required this.currUserRef,
        required this.reportedStatus,
        required this.tags})
      : super(key: key);

  @override
  _PostCard2State createState() => _PostCard2State();
}

class _PostCard2State extends State<PostCard2> {
  UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService();

  GroupsDatabaseService _groups = GroupsDatabaseService();



  bool liked = false;
  bool disliked = false;
  String userDomain = '<Loading user domain...>';
  String username = '<Loading user name...>';
  String groupName = '<Loading group name...>';
  Image groupImage = Image(image: AssetImage('assets/masonic-G.png'), height: 20, width: 20);

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.likes.contains(widget.currUserRef)) {
      setState(() {
        liked = true;
      });
    } else if (widget.dislikes.contains(widget.currUserRef)) {
      setState(() {
        disliked = true;
      });
    }
    // find username for userId
    // _userInfoDatabaseService.userId = widget.userId;
    getUserData();
    getGroupName();
    super.initState();
  }

  void getUserData() async {
    final UserData? fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.userRef);
    setState(() {
      username = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
      userDomain = fetchUserData != null ? fetchUserData.domain : '<Failed to retrieve user domain>';
    });
  }

  void getGroupName() async {
    final Group? fetchGroupName = await _groups.getGroupData(groupRef: widget.groupRef);
    setState(() {
      groupName = fetchGroupName != null ? fetchGroupName.name : '<Failed to retrieve group name>';
    });
  }

  void openSpecificGroupFeed() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SpecificGroupFeed(
            groupRef: widget.groupRef,
          )),
    );
  }
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostPage(
                  postInfo: Post(
                    postRef: widget.postRef,
                    userRef: widget.userRef,
                    groupRef: widget.groupRef,
                    title: widget.title,
                    LCtitle: widget.LCtitle,
                    text: widget.text,
                    media: widget.media,
                    createdAt: widget.createdAt,
                    likes: widget.likes,
                    dislikes: widget.dislikes,
                    numComments: widget.numComments,
                    reports: widget.reportedStatus,
                    tags: widget.tags,
                  ))),
        );
      },
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
          margin: EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 0.0),
          //color: HexColor("#292929"),
          elevation: 0.0,
          child: Container(
          /*
          constraints: BoxConstraints.expand(
            height: Theme.of(context).textTheme.headline4!.fontSize! * 1.1 + 200.0,
          ),
          */

          padding: const EdgeInsets.all(8.0),
          color: HexColor("FFFFFF"),
          alignment: Alignment(-1.0,-1.0), //Aligned to Top Left
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.account_circle, size:40, color:Colors.black),

                    //Spacer(),
                  ],
                ),
                SizedBox(width: 10),
                Flexible(  //Otherwise horizontal renderflew of row
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username + " • " + userDomain,
                        style: TextStyle(
                          fontWeight:FontWeight.w500,
                          fontSize: 15.0,
                          color: HexColor("#222426"),
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        groupName,
                        style: TextStyle(
                          fontWeight:FontWeight.bold,
                          fontSize: 15.0,
                          color: HexColor("#222426"),
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(     //TODO: Need to figure out ways to ref
                        widget.title,
                        style: TextStyle(
                          fontWeight:FontWeight.bold,
                          fontSize: 15.0,
                          color: HexColor("#222426"),
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.text,
                        overflow: TextOverflow.ellipsis, // default is .clip
                        maxLines: 3,
                        style: TextStyle(
                          fontWeight:FontWeight.bold,
                          fontSize: 15.0,
                          color: HexColor("#2F3031"),
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            //widget.createdAt.toString()
                            convertTime(widget.createdAt.toDate()),
                            style: TextStyle(
                              fontWeight:FontWeight.w500,
                              fontSize: 15.0,
                              color: HexColor("#2F3031"),
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.mode_comment_outlined,
                            color: Colors.black,
                            size: 15.0,
                          ),
                          Text(
                            widget.numComments.toString(),
                            style: TextStyle(
                              fontWeight:FontWeight.w500,
                              fontSize: 15.0,
                              color: HexColor("#2F3031"),
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                          Spacer(),
                          LikeDislikePost(
                              currUserRef: widget.currUserRef, postRef: widget.postRef, likes: widget.likes, dislikes: widget.dislikes
                          ),
                        ],
                      )
                    ], //Column Children ARRAY
                  ),
                )

              ],
            )
          )
      ),
    );
  }
}
