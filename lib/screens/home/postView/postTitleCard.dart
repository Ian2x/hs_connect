import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/profile/profilePage.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:hs_connect/shared/widgets/widgetDisplay.dart';
import 'package:provider/provider.dart';

class PostTitleCard extends StatefulWidget {
  final Post post;
  final Group group;
  final DocumentReference currUserRef;

  PostTitleCard({
    Key? key,
    required this.post,
    required this.group,
    required this.currUserRef,
  }) : super(key: key);

  @override
  _PostTitleCardState createState() => _PostTitleCardState();
}

class _PostTitleCardState extends State<PostTitleCard> {
  
  //final userData = Provider.of<UserData?>(context);

  bool liked = false;
  bool disliked = false;

  String? creatorName;

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
    getPostCreatorData();
    super.initState();
  }

  void getPostCreatorData() async {
    UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    final UserData? fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.post.creatorRef);
    if (mounted) {
      setState(() {
        creatorName = fetchUserData != null ? fetchUserData.displayedName : null;
      });
    }
  }

  void openCreatorProfile() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => pixelProvider(context, child: ProfilePage(
            profileRef: widget.post.creatorRef, currUserRef: widget.currUserRef,
          ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    final localCreatorName = creatorName != null ? creatorName! : '';

    return GestureDetector(
      onTap: () {
        openCreatorProfile();
      },
      child: Container(
          padding: EdgeInsets.fromLTRB(20*wp, 10*hp, 10*wp, 10*hp),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(  //intro row + three dots
                children: [
                  Text("from " + localCreatorName + " • " + convertTime(widget.post.createdAt.toDate()),
                    style: Theme.of(context).textTheme.subtitle2
                  ),
                  Spacer(flex:1),
                  IconButton(
                    icon: Icon(Icons.more_horiz),
                    iconSize: 20*hp,
                    onPressed: (){
                      showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20*hp),
                              )),
                          builder: (context) => pixelProvider(context, child: ReportSheet(
                            reportType: ReportType.post,
                            entityRef: widget.post.postRef,
                          )));

                    },
                  )
                ]
              ), //introRow
              Text( widget.post.title,
                style: Theme.of(context).textTheme.headline6
              ),
              SizedBox(height:8*hp),
              widget.post.text!= null && widget.post.text!=""?
                Text(widget.post.text!,
                  style: Theme.of(context).textTheme.headline5) : Container(),
              widget.post.mediaURL != null ?
                ImageContainer(imageString: widget.post.mediaURL!)
                  : Container(),
              widget.post.text!= null && widget.post.text!=""?
                  SizedBox(height:10*hp): Container(),
              SizedBox(height:10*hp),
              Row(
                children: [
                  GroupTag(groupImageURL: widget.group.image, groupName: widget.group.name,
                      groupColor: widget.group.hexColor != null ? HexColor(widget.group.hexColor!) : null, fontSize: 16*hp),
                  Spacer(),
                  LikeDislikePost(currUserRef: widget.currUserRef, post: widget.post),
                ],
              ),
              SizedBox(height:30*hp),
              Text(
                  widget.post.numComments + widget.post.numReplies < 2 ? 'Comments' : (widget.post.numComments + widget.post.numReplies).toString() + ' Comments',
                  style: Theme.of(context).textTheme.headline6,
              ),

            ],
          ),
        ),
    );
  }
}
