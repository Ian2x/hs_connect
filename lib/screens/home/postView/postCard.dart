import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  String? username;
  Group? group;

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
    super.initState();
  }

  void getUserData() async {
    UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.post.creatorRef, noDomainData: true);
    if (mounted) {
      setState(() {
        username = fetchUserData != null ? fetchUserData!.displayedName : null;
      });
    }
  }

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroup = await _groups.groupFromRef(widget.post.groupRef);
    if (fetchGroup != null) {
      if (mounted) {
        setState(() {
          group = fetchGroup;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    if (group==null || username==null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * hp)),
        margin: EdgeInsets.fromLTRB(5 * wp, 5 * hp, 5 * wp, 0),
        elevation: 0,
        child: Container(
          padding: EdgeInsets.fromLTRB(2 * wp, 12 * hp, 10 * wp, 10 * hp),
          height: 50 * hp
        )
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => pixelProvider(context,
                  child: PostPage(
                    post: widget.post,
                    group: group!,
                    creatorData: fetchUserData!,
                  ))),
        );
      },
      child: Card(
          //if border then ShapeDecoration
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * hp)),
          margin: EdgeInsets.fromLTRB(5 * wp, 5 * hp, 5 * wp, 0),
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
                                groupColor: group!.hexColor != null? HexColor(group!.hexColor!) : null,
                                groupImageURL: group!.image,
                                groupName: group!.name,
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
