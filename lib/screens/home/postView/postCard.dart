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
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';
import 'package:hs_connect/shared/widgets/widgetDisplay.dart';
import 'package:provider/provider.dart';


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
  String? groupImageString;
  Image? groupImage;
  String? groupColor;
  bool inDomain = false;
  Image? postImage;



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

  void getGroupData() async {

    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroup = await _groups.groupFromRef(widget.post.groupRef);
    if (mounted) {
      setState(() {
        if (fetchGroup!=null) {
          groupImageString = fetchGroup.image;
          groupName = fetchGroup.name;
          groupColor = fetchGroup.hexColor;
          if (fetchGroup.accessRestriction== AccessRestriction(restriction: groupName, restrictionType: AccessRestrictionType.domain)) {
            inDomain=true;
          }
        } else {
          groupName = '<Failed to retrieve group name>';
        }
        groupName = fetchGroup != null ? fetchGroup.name : '<Failed to retrieve group name>';

      });
    }
    if (widget.post.groupRef.id[0]=='@') {
      UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
      final tempUserData = await _userDataDatabaseService.getUserData(userRef: widget.currUserRef);
      if (tempUserData!=null && mounted && tempUserData.fullDomainName!=null) {
        setState(() {
          groupName = tempUserData.fullDomainName!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    if (groupImageString != null && groupImageString!="") {
      var tempImage = Image.network(groupImageString!);
      tempImage.image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
        if (mounted) {
          setState(() => groupImage = tempImage);
        }
      }));
    }
    if (widget.post.mediaURL!= null) {
      var tempImage = Image.network(widget.post.mediaURL!);
      tempImage.image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
        if (mounted) {
          setState(() => postImage = tempImage);
        }
      }));
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostPage(postRef: widget.post.postRef, currUserRef: widget.currUserRef,)),
        );
      },
      child: Card(
          //if border then ShapeDecoration
          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
          margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
          //color: HexColor("#292929"),
          elevation: 0,
          child: Container(
              padding: const EdgeInsets.fromLTRB(2,12,10,10),
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
                            Text("in ", style: ThemeText.inter(fontSize: 14, color: groupColor!=null ? HexColor(groupColor!) : ThemeColor.black)),
                            GroupTag( groupColor: groupColor != null ? HexColor(groupColor!) : null, groupImage:groupImage, groupName: groupName, fontSize:12),
                            Text(
                            " • " + convertTime(widget.post.createdAt.toDate()), style: ThemeText.inter(color: ThemeColor.mediumGrey, fontSize:14),
                            ),
                            Spacer(),
                            Icon(Icons.more_horiz),
                            SizedBox(width: 6),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          //TODO: Need to figure out ways to ref
                          widget.post.title,
                          style: ThemeText.roboto(fontSize: 18, color: ThemeColor.black), overflow: TextOverflow.ellipsis, // default is .clip
                          maxLines: 3
                        ),
                        widget.post.mediaURL != null ?
                            imageContainer(imageString: widget.post.mediaURL!)
                            :
                            Container(),
                        SizedBox(height: 8),
                        Row( //Icon Row
                          children: [
                            SizedBox(width:1),
                            Text(
                              (widget.post.numComments + widget.post.numReplies).toString()
                              + " Comments",
                              style: ThemeText.regularSmall(fontSize: 14, color: ThemeColor.mediumGrey),
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
