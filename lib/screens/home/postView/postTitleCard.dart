import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/poll.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/home/postView/pollView.dart';
import 'package:hs_connect/screens/profile/profilePage.dart';
import 'package:hs_connect/services/polls_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
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

  String? creatorName;
  Poll? poll;

  @override
  void initState() {
    // find username for userId
    getPostCreatorData();
    getPoll();
    super.initState();
  }

  void getPostCreatorData() async {
    UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    final UserData? fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.post.creatorRef);
    if (mounted) {
      setState(() {
        creatorName = fetchUserData != null ? fetchUserData.fundamentalName : null;
      });
    }
  }

  void getPoll() async {
    if (widget.post.pollRef!=null) {
      PollsDatabaseService _polls = PollsDatabaseService(pollRef: widget.post.pollRef!);
      final tempPoll = await _polls.getPoll();
      if (tempPoll!=null && mounted) {
        setState(()=>poll = tempPoll);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;
    final postLikesManager = Provider.of<PostLikesManager>(context);
    UserData? userData = Provider.of<UserData?>(context);

    final localCreatorName = creatorName != null ? creatorName! : '';

    return Container(
        padding: EdgeInsets.fromLTRB(20*wp, 10*hp, 10*wp, 10*hp),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(  //intro row + three dots
              children: [
                GestureDetector(
                  onTap: () {
                    if (userData!=null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => pixelProvider(context, child: ProfilePage(
                              profileRef: widget.post.creatorRef, currUserData: userData,
                            ))),
                      );
                    }
                  },
                  child: Text("from " + localCreatorName + " • " + convertTime(widget.post.createdAt.toDate()),
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary,
                    fontSize: 14*hp)
                  ),
                ),
                Spacer(flex:1),
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  iconSize: 20*hp,
                  color: colorScheme.primary,
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
              style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18*hp)
            ),
            SizedBox(height:8*hp),
            widget.post.text!= null && widget.post.text!=""?
              Text(widget.post.text!,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 16*hp)) : Container(),
            widget.post.mediaURL != null ?
              ImageContainer(imageString: widget.post.mediaURL!,
                hp:hp,
                containerWidth: MediaQuery.of(context).size.width,)
                : Container(),
            poll != null ? PollView(poll: poll!, currUserRef: widget.currUserRef, post: widget.post): Container(),
            SizedBox(height:20*hp),
            Row(
              children: [
                GroupTag(
                    groupImageURL: widget.group.image,
                    groupName: widget.group.name,
                    borderRadius: 20*hp,
                    padding: EdgeInsets.fromLTRB(9*wp, 4*hp, 9*wp, 4*hp),
                    thickness: 1.5*hp,
                    fontSize: 15*hp,
                ),
                Spacer(),
                LikeDislikePostStateful(currUserRef: widget.currUserRef, post: widget.post, postLikesManager: postLikesManager),
              ],
            ),
            SizedBox(height:30*hp),
            Text(
                widget.post.numComments + widget.post.numReplies < 2 ? 'Comments' : (widget.post.numComments + widget.post.numReplies).toString() + ' Comments',
                style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18*hp),
            ),

          ],
        ),
      );
  }
}
