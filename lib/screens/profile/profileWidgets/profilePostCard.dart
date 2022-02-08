import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/buildCircle.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class ProfilePostCard extends StatefulWidget {
  final Post post;
  final UserData currUserData;

  ProfilePostCard({Key? key, required this.post, required this.currUserData}) : super(key: key);

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
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    if (group == null) {
      return Container(
          height: 124 * hp,
          padding: EdgeInsets.fromLTRB(10 * wp, 0, 5 * wp, 10 * hp),
          decoration: ShapeDecoration(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * hp),
                side: BorderSide(
                  color: colorScheme.background,
                  width: 3 * hp,
                )),
          ),
          child: Loading(
            backgroundColor: Colors.transparent,
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
                      pixelProvider(context,
                          child: PostPage(post: widget.post, group: group!, creatorData: widget.currUserData, postLikesManager: postLikesManager, )))
          );
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(10 * wp, 0, 10 * wp, 10 * hp),
          decoration: ShapeDecoration(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * hp),
                side: BorderSide(
                  color: colorScheme.background,
                  width: 3 * hp,
                )),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(2*wp, 10*hp, 0, 0),
                child: Row(
                  children: [
                    buildGroupCircle(
                        groupImage: group!.image,
                        context: context,
                        height: 25*hp,
                        width: 25*hp,
                        backgroundColor: colorScheme.background),
                    SizedBox(width: 5*wp),
                    Text(group!.name, style: Theme.of(context).textTheme.subtitle2?.copyWith
                      (fontWeight: FontWeight.w500, color: colorScheme.primary))
                  ],
                ),
              ),
              SizedBox(height: 10 * hp),
              Text(widget.post.title, style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 10 * hp),
              Row(
                children: [
                  Text((widget.post.numComments + widget.post.numReplies).toString() + " Comments",
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.primary)),
                  Spacer(),
                  Text((likeCount-dislikeCount).toString() + " Likes", style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          )),
    );
  }
}
