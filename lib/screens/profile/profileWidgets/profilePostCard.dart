import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/screens/profile/profileWidgets/deletePostSheet.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/buildGroupCircle.dart';

import '../../../shared/tools/convertTime.dart';
import '../../../shared/widgets/message2_icons.dart';

class ProfilePostCard extends StatefulWidget {
  final Post post;
  final DocumentReference currUserRef;
  final VoidFunction onDelete;

  ProfilePostCard({Key? key, required this.post, required this.currUserRef, required this.onDelete}) : super(key: key);

  @override
  _ProfilePostCardState createState() => _ProfilePostCardState();
}

class _ProfilePostCardState extends State<ProfilePostCard> with AutomaticKeepAliveClientMixin<ProfilePostCard> {
  Group? group;
  Image? postImage;
  late bool likeStatus;
  late bool dislikeStatus;
  late int likeCount;
  late int dislikeCount;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    likeStatus = widget.post.likes.contains(widget.currUserRef);
    dislikeStatus = widget.post.dislikes.contains(widget.currUserRef);
    likeCount = widget.post.likes.length;
    dislikeCount = widget.post.dislikes.length;
    getGroupData();
    super.initState();
  }

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroup = await _groups.groupFromRef(widget.post.groupRef);
    if (fetchGroup != null && mounted) {
      setState(() {
        group = fetchGroup;
      });
    }
  }

  void onLike() {
    if (mounted) {
      setState(() {
        likeCount += 1;
        if (dislikeStatus == true) dislikeCount -= 1;
        likeStatus = true;
        dislikeStatus = false;
      });
    }
  }

  void onUnLike() {
    if (mounted) {
      setState(() {
        likeCount -= 1;
        likeStatus = false;
      });
    }
  }

  void onDislike() {
    if (mounted) {
      setState(() {
        dislikeCount += 1;
        if (likeStatus == true) likeCount -= 1;
        dislikeStatus = true;
        likeStatus = false;
      });
    }
  }

  void onUnDislike() {
    if (mounted) {
      setState(() {
        dislikeCount -= 1;
        dislikeStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final leftColumn = 40.0;
    final rightColumn = 20.0;

    if (group == null) {
      return Container(
          height: 80,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(left: 18, right: 18),
          child: Divider(height: 1, thickness: 1),

      );
    }

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          final postLikesManager = PostLikesManager(
              onLike: onLike,
              onUnLike: onUnLike,
              onDislike: onDislike,
              onUnDislike: onUnDislike,
              likeStatus: likeStatus,
              dislikeStatus: dislikeStatus,
              likeCount: likeCount,
              dislikeCount: dislikeCount);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PostPage(post: widget.post, group: group!, postLikesManager: postLikesManager)));
        },
        child: Column(
          children: [
            Container(padding: EdgeInsets.only(left: 18, right: 18), child: Divider(height: 1, thickness: 1)),
            Stack(children: [
              Container(
                padding: EdgeInsets.fromLTRB(leftColumn, 11, rightColumn, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.post.title,
                        style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3),
                    SizedBox(height: 9),
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 11, vertical: 2),
                            decoration:
                                BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Text(
                                  (widget.post.numComments + widget.post.numReplies).toString(),
                                  style: textTheme.headline6?.copyWith(fontSize: 15),
                                ),
                                SizedBox(width: 7),
                                Icon(Message2.message2, size: 14),
                              ],
                            )),
                        SizedBox(width: 10),
                        Text(
                          convertTime(widget.post.createdAt.toDate()),
                          style: textTheme.headline6?.copyWith(fontSize: 15),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          constraints: BoxConstraints(),
                          splashRadius: .1,
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.more_horiz, size: 19),
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    )),
                                builder: (context) => DeletePostSheet(
                                    currUserRef: widget.currUserRef,
                                    postUserRef: widget.post.creatorRef,
                                    groupRef: widget.post.groupRef,
                                    postRef: widget.post.postRef,
                                    media: widget.post.mediaURL,
                                    onDelete: widget.onDelete));
                          },
                        ),
                        Spacer(),
                        Text((likeCount - dislikeCount).toString() + " Likes",
                            style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                  left: 9.5,
                  top: 14,
                  child: buildGroupCircle(
                      groupImage: group!.image, context: context, size: 24)),
            ]),
          ],
        ));
  }
}
