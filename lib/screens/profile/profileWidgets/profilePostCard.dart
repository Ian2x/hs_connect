import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/screens/profile/profileWidgets/deletePostSheet.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/tools/buildCircle.dart';

class ProfilePostCard extends StatefulWidget {
  final Post post;
  final UserData currUserData;
  final VoidFunction onDelete;

  ProfilePostCard({Key? key, required this.post,
  required this.currUserData, required this.onDelete}) : super(key: key);

  @override
  _ProfilePostCardState createState() => _ProfilePostCardState();
}

class _ProfilePostCardState extends State<ProfilePostCard> {
  Group? group;
  Image? postImage;
  late bool likeStatus;
  late bool dislikeStatus;
  late int likeCount;
  late int dislikeCount;

  @override
  void initState() {
    likeStatus = widget.post.likes.contains(widget.currUserData.userRef);
    dislikeStatus = widget.post.dislikes.contains(widget.currUserData.userRef);
    likeCount = widget.post.likes.length;
    dislikeCount = widget.post.dislikes.length;
    getGroupData();
    super.initState();
  }

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserData.userRef);
    final Group? fetchGroup = await _groups.groupFromRef(widget.post.groupRef);
    if (fetchGroup != null && mounted) {
      setState(() {
        group = fetchGroup;
      });
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


    final colorScheme = Theme.of(context).colorScheme;

    if (group == null) {
      return Container(
          height: 124,
          padding: EdgeInsets.fromLTRB(10, 0, 5, 10),
          decoration: ShapeDecoration(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.background,
                  width: 3,
                )),
          ));
    }

    return GestureDetector(
        onTap: () {
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PostPage(post: widget.post, group: group!, creatorData: widget.currUserData, postLikesManager: postLikesManager))
          );
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          decoration: ShapeDecoration(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.background,
                  width: 1.5,
                )),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(2, 10, 0, 0),
                child: Row(
                  children: [
                    buildGroupCircle(
                        groupImage: group!.image,
                        context: context,
                        height: 20,
                        width: 20,
                        backgroundColor: colorScheme.background),
                    SizedBox(width: 5),
                    Text(group!.name, style: Theme.of(context).textTheme.subtitle2?.copyWith
                      (fontWeight: FontWeight.w500, color: colorScheme.primary, fontSize: postCardDetailSize)),
                    Spacer(),
                    IconButton(
                      constraints:BoxConstraints(),
                      padding: EdgeInsets.all(0),
                      icon:Icon(Icons.more_horiz, size:18, color: colorScheme.primary),
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                )),
                            builder: (context) => DeletePostSheet(
                                  currUserRef: widget.currUserData.userRef,
                                  postUserRef: widget.post.creatorRef,
                                  groupRef: widget.post.groupRef,
                                  postRef: widget.post.postRef,
                                  media: widget.post.mediaURL,
                                  onDelete: widget.onDelete
                          ));
                      },
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(widget.post.title, style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 16), overflow: TextOverflow.ellipsis, maxLines: 3),
              SizedBox(height: 10),
              Row(
                children: [
                  Text((widget.post.numComments + widget.post.numReplies).toString() + " Comments",
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.primary, fontSize: postCardDetailSize)),
                  Spacer(),
                  Text((likeCount-dislikeCount).toString() + " Likes", style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w500, fontSize: postCardDetailSize)),
                ],
              ),
            ],
          )),
    );
  }
}
