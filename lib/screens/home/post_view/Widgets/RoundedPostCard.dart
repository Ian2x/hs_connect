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
import 'package:hs_connect/screens/home/comment_view/comment_form.dart';
import 'package:provider/provider.dart';


class RoundedPostCard extends StatefulWidget {
 final Post postInfo;
 final DocumentReference userRef;

 RoundedPostCard(
     {Key? key,
      required this.postInfo,
      required this.userRef,
     })
     : super(key: key);

 @override
 _RoundedPostCardState createState() => _RoundedPostCardState();
}

class _RoundedPostCardState extends State<RoundedPostCard> {
 UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService();

 GroupsDatabaseService _groups = GroupsDatabaseService();

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
  if (widget.postInfo.likes.contains(widget.userRef)) {
   setState(() {
    liked = true;
   });
  } else if (widget.postInfo.dislikes.contains(widget.userRef)) {
   setState(() {
    disliked = true;
   });
  }
  // find username for userId
  // _userInfoDatabaseService.userId = widget.postInfo.userId;
  getUserData();
  getGroupName();
  super.initState();
 }

 void getUserData() async {
  final UserData? fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.postInfo.userRef);
  setState(() {
   username = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
   userDomain = fetchUserData != null ? fetchUserData.domain : '<Failed to retrieve user domain>';
  });
 }

 void getGroupName() async {
  final Group? fetchGroupName = await _groups.getGroupData(groupRef: widget.postInfo.groupRef);
  setState(() {
   groupName = fetchGroupName != null ? fetchGroupName.name : '<Failed to retrieve group name>';
  });
 }

 void openSpecificGroupFeed() async {
  print("adsf");
  Navigator.push(
   context,
   MaterialPageRoute(
       builder: (context) => SpecificGroupFeed(
        groupRef: widget.postInfo.groupRef,
       )),
  );
 }

 @override
 Widget build(BuildContext context) {


  return Card(
       margin: EdgeInsets.fromLTRB(6.0, 1.0, 6.0, 0.0),
       elevation: 0.0,
       child: Container(
           decoration:
             ShapeDecoration(
             color: HexColor('FFFFFF'),
             shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13.0),
              side: BorderSide(
                 color: HexColor("E9EDF0"),
                 width: 3.0,
               )
              ),
             ),
           padding: const EdgeInsets.all(8.0),
           //color: HexColor("FFFFFF"),
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
                 widget.postInfo.title,
                 style: TextStyle(
                  fontWeight:FontWeight.bold,
                  fontSize: 15.0,
                  color: HexColor("#222426"),
                  fontFamily: 'Segoe UI',
                 ),
                ),
                SizedBox(height: 10),
                Text(
                 widget.postInfo.text,
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
                   //widget.postInfo.createdAt.toString()
                   convertTime(widget.postInfo.createdAt.toDate()),
                   style: TextStyle(
                    fontWeight:FontWeight.w500,
                    fontSize: 15.0,
                    color: HexColor("#2F3031"),
                    fontFamily: 'Segoe UI',
                   ),
                  ),
                  Spacer(),
                  IconButton(
                   icon:Icon(Icons.mode_comment_outlined,
                   color: Colors.black,
                   size: 15.0),
                   onPressed: (){
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) => CommentForm(postRef: widget.postInfo.postRef)),
                    );
                   },
                  ),
                  Text(
                   widget.postInfo.numComments.toString(),
                   style: TextStyle(
                    fontWeight:FontWeight.w500,
                    fontSize: 15.0,
                    color: HexColor("#2F3031"),
                    fontFamily: 'Segoe UI',
                   ),
                  ),
                  Spacer(),
                  LikeDislikePost(
                      currUserRef: widget.userRef, postRef: widget.postInfo.postRef, likes: widget.postInfo.likes, dislikes: widget.postInfo.dislikes
                  ),
                 ],
                )
               ], //Column Children ARRAY
              ),
             )

            ],
           )
       )
   );
 }
}
