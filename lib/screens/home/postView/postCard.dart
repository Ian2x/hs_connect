import 'dart:ui' as ui;
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/poll.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/home/postView/pollView.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/polls_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/buildGroupCircle.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:hs_connect/shared/widgets/expandableImage.dart';
import 'package:hs_connect/shared/widgets/message2_icons.dart';
import 'package:hs_connect/shared/widgets/myLinkPreview.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../services/storage/image_storage.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final UserData currUserData;

  PostCard({Key? key, required this.post, required this.currUserData}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin<PostCard> {
  static const leftRightMargin = 6.0;
  final GlobalKey shareKey = GlobalKey();

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
  PreviewData? previewData;

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

  Future<void> share() async {
    RenderObject? boundary = shareKey.currentContext?.findRenderObject();
    if (boundary.runtimeType == RenderRepaintBoundary) {
      RenderRepaintBoundary boundary2 = boundary as RenderRepaintBoundary;
      if (boundary2.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        return share();
      }
      final image = await boundary2.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes!=null) {
        final filePath = await writeToFile(bytes);
        // final shareURL = await ImageStorage().uploadShare(file: file);
        Share.shareFiles([filePath]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final leftColumn = 40.0;
    final rightColumn = 40.0;

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

    final contentWidth = MediaQuery.of(context).size.width - 2 * leftRightMargin - leftColumn - rightColumn;

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
      child: RepaintBoundary(
        key: shareKey,
        child: /*Bubble(
          margin: BubbleEdges.fromLTRB(leftRightMargin, 6, leftRightMargin, 6),
          color: colorScheme.background,
          padding: BubbleEdges.fromLTRB(10, 10, 5, 10),
          // nip: widget.post.creatorRef != widget.currUserData.userRef ? BubbleNip.leftBottom : BubbleNip.rightBottom,
          elevation: 0,
          radius: Radius.circular(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildGroupCircle(
                      groupImage: creatorImage, size: 28, context: context, backgroundColor: colorScheme.background),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post.title,
                          style: textTheme.headline6,
                          overflow: TextOverflow.ellipsis, // default is .clip
                          maxLines: 8),
                      widget.post.link != null
                          ? Container(
                        margin: EdgeInsets.only(top: 8),
                        child: MyLinkPreview(
                            enableAnimation: true,
                            onPreviewDataFetched: (data) {
                              if (mounted) {
                                setState(() => previewData = data);
                              }
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
                        margin: EdgeInsets.only(top: 8),
                      )
                          : Container(),
                      poll != null
                          ? Container(
                          margin: EdgeInsets.only(top: 8),
                          alignment: Alignment.center,
                          width: contentWidth,
                          child: PollView(poll: poll!, currUserRef: widget.currUserData.userRef, post: widget.post))
                          : Container(),
                    ]
                  ),
                  Spacer(),
                  LikeDislikePost(
                    currUserRef: widget.currUserData.userRef,
                    post: widget.post,
                    postLikesManager: postLikesManager,
                    currUserColor: widget.currUserData.domainColor,
                  ),
                ]
              ),
              Row(
                children: [
                  SizedBox(width: 20),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 3),
                      decoration: BoxDecoration(
                          color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Text(
                            (widget.post.numComments + widget.post.numReplies).toString(),
                            style: textTheme.headline6?.copyWith(fontSize: 17),
                          ),
                          SizedBox(width: 7),
                          Icon(Message2.message2, size: 16),
                          widget.currUserData.userRef != widget.post.creatorRef
                              ? Row(
                            children: [
                              SizedBox(width: 15),
                              IconButton(
                                constraints: BoxConstraints(),
                                splashRadius: .1,
                                padding: EdgeInsets.zero,
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
                              ),
                            ],
                          )
                              : Container(),
                        ],
                      )),
                  SizedBox(width: 11),
                  Text(
                    convertTime(widget.post.createdAt.toDate()),
                    style: textTheme.headline6?.copyWith(fontSize: 17),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 2, 10, 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: widget.currUserData.domainColor ?? colorScheme.primary
                    ),
                    child: GestureDetector(
                        onTap: () async {
                          await share();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.ios_share_rounded, size: 18, color: colorScheme.brightness == Brightness.light ? colorScheme.surface : colorScheme.onSurface),
                            SizedBox(width: 5),
                            Text("Share", style: textTheme.headline6?.copyWith(fontSize: 17, color: colorScheme.brightness == Brightness.light ? colorScheme.surface : colorScheme.onSurface)),
                          ],
                        )),
                  ),
                ],
              )
            ],
          ),
        )*/

        Stack(
          children: [
            Bubble(
              margin: BubbleEdges.fromLTRB(leftRightMargin, 6, leftRightMargin, 6),
              color: colorScheme.background,
              padding: BubbleEdges.fromLTRB(leftColumn, 10, rightColumn, 10),
              // nip: widget.post.creatorRef != widget.currUserData.userRef ? BubbleNip.leftBottom : BubbleNip.rightBottom,
              elevation: 0,
              radius: Radius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.post.title,
                      style: textTheme.headline6,
                      overflow: TextOverflow.ellipsis, // default is .clip
                      maxLines: 8),
                  widget.post.link != null
                      ? Container(
                          margin: EdgeInsets.only(top: 8),
                          child: MyLinkPreview(
                              enableAnimation: true,
                              onPreviewDataFetched: (data) {
                                if (mounted) {
                                  setState(() => previewData = data);
                                }
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
                          margin: EdgeInsets.only(top: 8),
                        )
                      : Container(),
                  poll != null
                      ? Container(
                          margin: EdgeInsets.only(top: 8),
                          alignment: Alignment.center,
                          width: contentWidth,
                          child: PollView(poll: poll!, currUserRef: widget.currUserData.userRef, post: widget.post))
                      : Container(),
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 3),
                            decoration: BoxDecoration(
                                color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Text(
                                  (widget.post.numComments + widget.post.numReplies).toString(),
                                  style: textTheme.headline6?.copyWith(fontSize: 17),
                                ),
                                SizedBox(width: 7),
                                Icon(Message2.message2, size: 16),
                                widget.currUserData.userRef != widget.post.creatorRef
                                    ? Row(
                                        children: [
                                          SizedBox(width: 15),
                                          IconButton(
                                            constraints: BoxConstraints(),
                                            splashRadius: .1,
                                            padding: EdgeInsets.zero,
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
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ],
                            )),
                        SizedBox(width: 11),
                        Text(
                          convertTime(widget.post.createdAt.toDate()),
                          style: textTheme.headline6?.copyWith(fontSize: 17),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 3, 10, 6),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: widget.currUserData.domainColor ?? colorScheme.primary
                          ),
                          child: GestureDetector(
                              onTap: () async {
                                await share();
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.ios_share_rounded, size: 18, color: colorScheme.brightness == Brightness.light ? colorScheme.surface : colorScheme.onSurface),
                                  SizedBox(width: 5),
                                  Text("Share", style: textTheme.headline6?.copyWith(fontSize: 17, color: colorScheme.brightness == Brightness.light ? colorScheme.surface : colorScheme.onSurface)),
                                ],
                              )),
                        ),
                      ],
                    ),
                  )
                ], //Column Children ARRAY
              ),
            ),
            Positioned(
              left: 12.5,
              top: 17.5,
              child: buildGroupCircle(
                  groupImage: creatorImage, size: 28, context: context, backgroundColor: colorScheme.background),
            ),
            Positioned(
              right:5,
              top:10,
              child: LikeDislikePost(
                currUserRef: widget.currUserData.userRef,
                post: widget.post,
                postLikesManager: postLikesManager,
                currUserColor: widget.currUserData.domainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
