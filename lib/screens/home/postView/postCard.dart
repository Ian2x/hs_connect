import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
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
  String? username;
  Group? group;
  late bool likeStatus;
  late bool dislikeStatus;
  late int likeCount;
  late int dislikeCount;
  UserData? fetchUserData;

  @override
  void initState() {
    likeStatus = widget.post.likes.contains(widget.currUserRef);
    dislikeStatus = widget.post.dislikes.contains(widget.currUserRef);
    likeCount = widget.post.likes.length;
    dislikeCount = widget.post.dislikes.length;
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
  void onLike() {
    if (mounted) { setState(() {
      likeCount += 1;
      if (dislikeStatus == true) dislikeCount -= 1;
      likeStatus = true;
      dislikeStatus = false;
    });}
  }

  void onUnLike() {
    if (mounted) { setState(() {
      likeCount -= 1;
      likeStatus = false;
    });}
  }

  void onDislike () {
    if (mounted) { setState(() {
      dislikeCount += 1;
      if (likeStatus == true) likeCount -= 1;
      dislikeStatus = true;
      likeStatus = false;
    });}
  }

  void onUnDislike () {
    if (mounted) { setState(() {
      dislikeCount-=1;
      dislikeStatus=false;
    });}
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    if (group==null || username==null) {
      return Container();
    }

    final postLikesManager = PostLikesManager(
        onLike: onLike,
        onUnLike: onUnLike,
        onDislike: onDislike,
        onUnDislike: onUnDislike,
        likeStatus: likeStatus,
        dislikeStatus: dislikeStatus,
        likeCount: likeCount,
        dislikeCount: dislikeCount
    );

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
                    postLikesManager: postLikesManager
                  ))),
        );
      },
      child: Card(
          //if border then ShapeDecoration
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * hp)),
          margin: EdgeInsets.fromLTRB(5 * wp, 3 * hp, 5 * wp, 3*hp),
          elevation: 0,
          child: Container(
              padding: EdgeInsets.fromLTRB(2 * wp, 2 * hp, 5 * wp, 5 * hp),
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
                            Chip(
                              padding: EdgeInsets.all(0),
                              backgroundColor: colorScheme.surface,
                              avatar: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: colorScheme.primary,
                                    border: Border.all(
                                        width: 0.15*hp
                                    )
                                ),
                                child: CircleAvatar(
                                  backgroundColor: colorScheme.surface,
                                  backgroundImage: ImageStorage().groupImageProvider(group!=null ? group!.image : null),
                                ),
                              ),
                              label: Text(
                                group!.name,
                                  style: Theme.of(context).textTheme.subtitle2?.copyWith
                                    (color: Theme.of(context).primaryColorDark,
                                      fontSize: 15 * hp, fontWeight: FontWeight.w500),
                                )
                            ),
                            Text(
                              " • " + convertTime(widget.post.createdAt.toDate()),
                              style: Theme.of(context).textTheme.subtitle2?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        Text(
                            widget.post.title,
                            style: Theme.of(context).textTheme.headline6?.copyWith(
                              fontSize:18 * hp, fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis, // default is .clip
                            maxLines: 3),
                        widget.post.mediaURL != null ? ImageContainer(imageString: widget.post.mediaURL!)
                            : Container(),
                        Row(
                          //Icon Row
                          children: [
                            SizedBox(width: 1 * wp),
                            Text(
                              (widget.post.numComments + widget.post.numReplies).toString() + " Comments",
                              style: Theme.of(context).textTheme.subtitle2?.copyWith
                                (fontSize: 14 * hp, fontWeight: FontWeight.normal),
                            ),
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
                            Spacer(),
                            LikeDislikePost(
                                currUserRef: widget.currUserRef,
                                post: widget.post,
                                postLikesManager: postLikesManager
                            ),
                            SizedBox(width: 5*hp),
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
