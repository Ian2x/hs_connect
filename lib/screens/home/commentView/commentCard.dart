import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/screens/home/commentView/likeDislikeComment.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/home/replyFeed/replyFeed.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final DocumentReference currUserRef;

  CommentCard({
    Key? key,
    required this.comment,
    required this.currUserRef,
  }) : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';
  String? imageString;
  Image? userImage;
  String userGroupName='';

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.comment.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          liked = true;
        });
      }
    } else if (widget.comment.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          disliked = true;
        });
      }
    }
    getUserData();
    super.initState();
  }





  void getUserData() async {
    if (widget.comment.creatorRef != null) {
      UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
      final UserData? fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.comment.creatorRef);
      if (mounted) {
        setState(() {
          username = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
          userGroupName = fetchUserData != null ? fetchUserData.domain : '<Failed to retrieve user name>';
          imageString = fetchUserData != null ? fetchUserData.profileImage : '<Failed to retrieve user name>';
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

    double imageSide= (MediaQuery.of(context).size.width)/12;

    if (imageString != null && imageString != "") {
      var tempImage = Image.network(imageString!);
      tempImage.image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo image, bool syncrhonousCall) {
        if (mounted) {
          setState(() => userImage = tempImage);
        }
      }));
    } else {
      userImage=  Image(image: AssetImage('assets/lville.jpeg'), height: 20, width: 20);
    }

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 10.0),
          child: Center(
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
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
                  ),
                  SizedBox(width:10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          child: IconButton(icon: Icon(Icons.more_horiz),
                            iconSize: 20,
                            onPressed: (){},
                          ),
                        ),
                        Row( //Text Row
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(text: username + " ",style: ThemeText.groupBold(color: ThemeColor.mediumGrey, fontSize: 15)),
                                    TextSpan(text: widget.comment.text,style: ThemeText.postViewText(color: ThemeColor.black, fontSize: 15)),
                                  ],
                                ),
                              ),
                            ]),
                        SizedBox(height:10),
                        Row(
                          children: [
                            Text(
                              userGroupName, style: ThemeText.groupBold(color:ThemeColor.mediumGrey, fontSize:14),
                            ),
                            Spacer(flex:1),
                            TextButton(
                                child: Text("Reply", style: ThemeText.groupBold(color:ThemeColor.mediumGrey, fontSize:14)),
                                onPressed: (){}
                            ),
                            SizedBox(width: 10),
                            LikeDislikeComment(
                                commentRef: widget.comment.commentRef,
                                currUserRef: widget.currUserRef,
                                likes: widget.comment.likes,
                                dislikes: widget.comment.dislikes
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          //RepliesFeed(commentRef: widget.comment.commentRef, postRef: widget.comment.postRef, groupRef: widget.comment.groupRef),
          Divider(thickness: 3, color: ThemeColor.backgroundGrey, height: 20),
          Positioned(
            right:10,
            top:10,
            child:Text("hell0"),
          )
        ]),
            )),
      ],
    );
  }
}
