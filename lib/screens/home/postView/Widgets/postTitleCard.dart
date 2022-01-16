import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/profile/profilePage.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';

class postTitleCard extends StatefulWidget {
  Post post;
  DocumentReference currUserRef;

  postTitleCard({
    Key? key,
    required this.post,
    required this.currUserRef,
  }) : super(key: key);

  @override
  _postTitleCardState createState() => _postTitleCardState();
}

class _postTitleCardState extends State<postTitleCard> {
  
  //final userData = Provider.of<UserData?>(context);

  bool liked = false;
  bool disliked = false;
  int commentCount=0;
  String commentString="Comments";
  String? imageString;
  Color groupColor = ThemeColor.darkGrey;
  String userDomain = '';
  String creatorName = '';
  String groupName = '';
  Image? groupImage;

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
    getGroupData();
    super.initState();
    getCommentCount();
  }

  void getCommentCount()async {
    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.currUserRef);
    final post = await  _posts.getPost(widget.post.postRef);
    setState(() {
      commentCount= post != null ? post.numComments + post.numReplies: 0;
    });
  }



  void getUserData() async {
    UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    final UserData? fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.post.creatorRef);
    if (mounted) {
      setState(() {
        creatorName = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
        userDomain = fetchUserData != null ? fetchUserData.domain : '<Failed to retrieve user domain>';
      });
    }
  }

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroupData = await _groups.groupFromRef(widget.post.groupRef);
    if (fetchGroupData != null) {
      if (mounted) {
        setState(() {
          groupName = fetchGroupData.name;
          if (fetchGroupData.hexColor != null) groupColor = HexColor(fetchGroupData.hexColor!);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          groupName = '<Failed to retrieve group name>';
        });
      }
    }
  }

  void openCreatorProfile() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfilePage(
                profileRef: widget.post.creatorRef, currUserRef: widget.currUserRef,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (imageString != null && imageString!="") {
      var tempImage = Image.network(imageString!);
      tempImage.image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
        if (mounted) {
          setState(() => groupImage = tempImage);
        }
      }));
    } else {
      groupImage=  Image(image: AssetImage('assets/masonic-G.png'), height: 20, width: 20);
    }

    if (commentCount <2) {
      commentString="Comments";
    } else {
      commentString = commentCount.toString() + " Comments";
    }

    return GestureDetector(
      onTap: () {
        openCreatorProfile();
      },
      child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(  //intro row + three dots
                children: [
                  Text("from " + creatorName + " • " + convertTime(widget.post.createdAt.toDate()),
                    style: ThemeText.regularSmall(color:ThemeColor.mediumGrey,fontSize:14)
                  ),
                  Spacer(flex:1),
                  IconButton(
                    icon: Icon(Icons.more_horiz),
                    iconSize: 20,
                    onPressed: (){},
                  )
                ]
              ), //introRow
              SizedBox(height:0),
              Text( widget.post.title,
                style: ThemeText.postViewTitle(fontSize:18, color: ThemeColor.black, height:1.5),
              ),
              SizedBox(height:8),
              widget.post.text!= null ?
                Text( widget.post.text!,
                  style: ThemeText.postViewText(fontSize:16, color: ThemeColor.mediumGrey, height: 1.5)) : Container(),
              widget.post.text!= null ?  SizedBox(height:20): Container(),
              Row(
                children: [
                  GroupTag(groupImage: groupImage, groupName: groupName,
                      groupColor: groupColor),
                  Spacer(),
                  LikeDislikePost(currUserRef: widget.currUserRef, postRef: widget.post.postRef,
                      likes: widget.post.likes, dislikes: widget.post.dislikes),
                ],
              ),
              SizedBox(height:30),
              Text(
                  commentString,
                  style: ThemeText.groupBold( fontSize:20, color: ThemeColor.darkGrey),
              ),

            ],
          ),
        ),
    );
  }
}
