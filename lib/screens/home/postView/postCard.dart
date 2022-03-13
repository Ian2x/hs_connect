import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/poll.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/dmButton.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/home/postView/pollView.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/polls_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/buildGroupCircle.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/expandableImage.dart';
import 'package:hs_connect/shared/widgets/myLinkPreview.dart';

import '../../../shared/widgets/chatIcons.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final UserData currUserData;

  PostCard({Key? key, required this.post, required this.currUserData}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin<PostCard> {
  static const leftRightMargin = 10.0;

  @override
  bool get wantKeepAlive => true;

  String? creatorImage;
  Group? group;
  late bool likeStatus;
  late bool dislikeStatus;
  late int likeCount;
  late int dislikeCount;
  OtherUserData? fetchUserData;
  Poll? poll;

  @override
  void initState() {
    likeStatus = widget.post.likes.contains(widget.currUserData.userRef);
    dislikeStatus = widget.post.dislikes.contains(widget.currUserData.userRef);
    likeCount = widget.post.likes.length;
    dislikeCount = widget.post.dislikes.length;
    getUserData();
    getGroupData();
    getPoll();
    super.initState();
  }

  void getUserData() async {
    UserDataDatabaseService _userDataDatabaseService =
        UserDataDatabaseService(currUserRef: widget.currUserData.userRef);
    fetchUserData =
        await _userDataDatabaseService.getOtherUserData(userRef: widget.post.creatorRef, noDomainData: false);
    if (mounted) {
      setState(() {
        creatorImage = fetchUserData != null ? fetchUserData!.domainImage : null;
      });
    }
  }

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserData.userRef);
    final Group? fetchGroup = await _groups.groupFromRef(widget.post.groupRef);
    if (fetchGroup != null) {
      if (mounted) {
        setState(() {
          group = fetchGroup;
        });
      }
    }
  }

  Future<void> getPoll() async {
    if (widget.post.pollRef != null) {
      PollsDatabaseService _polls = PollsDatabaseService(pollRef: widget.post.pollRef!);
      final tempPoll = await _polls.getPoll();
      if (tempPoll != null && mounted) {
        setState(() => poll = tempPoll);
      }
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

  PreviewData? previewData;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (group == null) {
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
        dislikeCount: dislikeCount);

    final contentWidth = MediaQuery.of(context).size.width - 2 * leftRightMargin - 12;
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostPage(post: widget.post, group: group!, postLikesManager: postLikesManager)),
        );
        if (widget.post.pollRef != null) {
          if (mounted) {
            setState(() => poll = null);
          }
          await getPoll();
        }
      },
      child: Stack(
        children: [
          Bubble(
              margin: BubbleEdges.fromLTRB(leftRightMargin + 12, 8, leftRightMargin, 8),
              color: colorScheme.background,
              padding: BubbleEdges.all(0),
              // nip: widget.post.creatorRef != widget.currUserData.userRef ? BubbleNip.leftBottom : BubbleNip.rightBottom,
              elevation: 0,
              radius: Radius.circular(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(18, 13, 18, 0),
                    child: Text(widget.post.title,
                        style: textTheme.headline6?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis, // default is .clip
                        maxLines: 3),
                  ),
                  SizedBox(height: 5),
                  widget.post.link != null
                      ? Container(
                          margin: EdgeInsets.only(top: 10),
                          child: MyLinkPreview(
                              enableAnimation: true,
                              onPreviewDataFetched: (data) {
                                setState(() => previewData = data);
                              },
                              metadataTitleStyle: textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold),
                              metadataTextStyle: textTheme.subtitle1?.copyWith(fontSize: 14),
                              previewData: previewData,
                              text: widget.post.link!,
                              textStyle: textTheme.subtitle2,
                              linkStyle: textTheme.subtitle2,
                              width: contentWidth),
                        )
                      : Container(),
                  widget.post.mediaURL != null
                      ? ExpandableImage(
                          imageURL: widget.post.mediaURL!,
                          containerWidth: contentWidth,
                          maxHeight: contentWidth * 4 / 3,
                          margin: EdgeInsets.only(top: 10))
                      : Container(),
                  poll != null
                      ? Container(
                          alignment: Alignment.center,
                          width: contentWidth,
                          child: PollView(poll: poll!, currUserRef: widget.currUserData.userRef, post: widget.post))
                      : Container(),
                  Container(
                    padding: EdgeInsets.fromLTRB(18, 0, 5, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          (widget.post.numComments + widget.post.numReplies).toString(),
                          style: textTheme.headline6,
                        ),
                        SizedBox(width: 7),
                        Icon(Icons.chat_bubble_outline_rounded, size: 21),
                        SizedBox(width: 15),
                        widget.currUserData.userRef != widget.post.creatorRef
                            ? IconButton(
                                constraints: BoxConstraints(),
                                splashRadius: .1,
                                icon: Icon(Icons.more_horiz, size: 21),
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      )),
                                      builder: (context) => ReportSheet(
                                            reportType: ReportType.post,
                                            entityRef: widget.post.postRef,
                                            entityCreatorRef: widget.post.creatorRef,
                                          ));
                                },
                              )
                            : Container(),
                        Spacer(),
                        Container(
                          child: LikeDislikePost(
                            currUserRef: widget.currUserData.userRef,
                            post: widget.post,
                            postLikesManager: postLikesManager,
                            currUserColor: widget.currUserData.domainColor,
                          ),
                        ),
                      ],
                    ),
                  )
                ], //Column Children ARRAY
              )),
          Positioned(
            left: 0,
            top: 18,
            child: buildGroupCircle(
                groupImage: creatorImage,
                size: 17,
                context: context,
                backgroundColor: colorScheme.surface),
          )
        ],
      ),
    );
  }
}
