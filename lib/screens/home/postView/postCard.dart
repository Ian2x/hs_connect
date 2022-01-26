import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
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

  UserData? fetchUserData;

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
    getPostMedia();
    super.initState();
  }

  void getPostMedia() async {
    if (widget.post.mediaURL != null) {
      var tempImage = Image.network(widget.post.mediaURL!);
      tempImage.image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
        if (mounted) {
          setState(() => postImage = tempImage);
        }
      }));
    }
  }

  void getUserData() async {
    UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.post.creatorRef);
    if (mounted) {
      setState(() {
        username = fetchUserData != null ? fetchUserData!.displayedName : '<Failed to retrieve user name>';
        userDomain = fetchUserData != null ? fetchUserData!.domain : '<Failed to retrieve user domain>';
      });
    }
  }

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroup = await _groups.groupFromRef(widget.post.groupRef);
    if (mounted) {
      setState(() {
        if (fetchGroup != null) {
          groupImageString = fetchGroup.image;
          groupName = fetchGroup.name;
          groupColor = fetchGroup.hexColor;
          if (fetchGroup.accessRestriction ==
              AccessRestriction(restriction: groupName, restrictionType: AccessRestrictionType.domain)) {
            inDomain = true;
          }
          if (groupImageString != null && groupImageString != "") {
            var tempImage = Image.network(groupImageString!);
            tempImage.image
                .resolve(ImageConfiguration())
                .addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
              if (mounted) {
                setState(() => groupImage = tempImage);
              }
            }));
          }
        } else {
          groupName = '<Failed to retrieve group name>';
        }
      });
    }
    // TODO: look at this
    /*
    if (widget.post.accessRestriction.restrictionType==AccessRestrictionType.domain) {
      GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
      final groupData = await _groups.getGroup(widget.post.groupRef);
    }*/
    if (widget.post.groupRef.id[0] == '@') {
      UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
      final tempUserData = await _userDataDatabaseService.getUserData(userRef: widget.post.creatorRef);
      if (tempUserData != null && mounted && tempUserData.fullDomainName != null) {
        setState(() {
          groupName = tempUserData.fullDomainName!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => pixelProvider(context,
                  child: PostPage(
                    postRef: widget.post.postRef,
                    currUserRef: widget.currUserRef,
                    userData: fetchUserData!,
                  ))),
        );
      },
      child: Card(
          //if border then ShapeDecoration
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * hp)),
          margin: EdgeInsets.fromLTRB(5 * wp, 5 * hp, 5 * wp, 0),
          //color: HexColor("#292929"),
          elevation: 0,
          child: Container(
              padding: EdgeInsets.fromLTRB(2 * wp, 12 * hp, 10 * wp, 10 * hp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10 * wp),
                  Flexible(
                    //Otherwise horizontal renderflew of row
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            //Text("in ", style: ThemeText.inter(fontSize: 14, color: groupColor!=null ? HexColor(groupColor!) : colorScheme.primary)),
                            GroupTag(
                                groupColor: groupColor != null ? HexColor(groupColor!) : null,
                                groupImage: groupImage,
                                groupName: groupName,
                                fontSize: 14 * hp),
                            Text(
                              " • " + convertTime(widget.post.createdAt.toDate()),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            Spacer(),
                            IconButton(
                              constraints: BoxConstraints(),
                              splashRadius: .1,
                              icon: Icon(Icons.more_horiz, size: 20 * hp, color: colorScheme.primary),
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20 * hp),
                                    )),
                                    builder: (context) => pixelProvider(context,
                                        child: ReportSheet(
                                          reportType: ReportType.post,
                                          entityRef: widget.post.postRef,
                                        )));
                              },
                            ),
                            SizedBox(width: 6 * wp),
                          ],
                        ),
                        SizedBox(height: 10 * hp),
                        Text(
                            //TODO: Need to figure out ways to ref
                            widget.post.title,
                            style: Theme.of(context).textTheme.headline6,
                            overflow: TextOverflow.ellipsis, // default is .clip
                            maxLines: 3),
                        widget.post.mediaURL != null ? ImageContainer(imageString: widget.post.mediaURL!) : Container(),
                        SizedBox(height: 8 * hp),
                        Row(
                          //Icon Row
                          children: [
                            SizedBox(width: 1 * wp),
                            Text(
                              (widget.post.numComments + widget.post.numReplies).toString() + " Comments",
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            Spacer(),
                            LikeDislikePost(currUserRef: widget.currUserRef, post: widget.post),
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
