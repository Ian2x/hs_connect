import 'dart:ui' as ui;
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:hs_connect/models/accessRestriction.dart';
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
import 'package:share_plus/share_plus.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final UserData currUserData;

  PostCard({Key? key, required this.post, required this.currUserData}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin<PostCard> {
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
      final image = await boundary2.toImage(pixelRatio: 4);
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

    final leftColumn = 50.0;
    final rightColumn = 45.0;

    double specialPadding =0;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (group == null) {
      return Container();
    }

    if (widget.post.accessRestriction.restrictionType == AccessRestrictionType.domain
        || widget.post.isFeatured
    ){
      specialPadding=20;
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

    final contentWidth = MediaQuery.of(context).size.width - leftColumn - rightColumn;

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
      child: Column(
        children: [
          Container(padding: EdgeInsets.only(left: 26, right: 24), child: Divider(height: 1, thickness: 1)),
          RepaintBoundary(
            key: shareKey,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(leftColumn, 15, rightColumn, 20),
                  color: colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.post.isFeatured != false ?
                      Row(
                        children: [
                          Text(widget.post.title,
                              style: textTheme.headline6?.copyWith(
                                color: widget.currUserData.domainColor ?? colorScheme.primary,
                                fontSize:14,
                                fontWeight:FontWeight.w500,
                                ),
                              ),
                          Icon(Icons.local_fire_department, color: widget.currUserData.domainColor ?? colorScheme.primary),
                        ],
                      ): Container(),
                      widget.post.accessRestriction.restrictionType == AccessRestrictionType.domain ?
                      Row(
                        children: [
                          Text(group!.name,
                              style: textTheme.headline6?.copyWith(
                                color: widget.currUserData.domainColor ?? colorScheme.primary,
                                fontSize:14,
                                fontWeight:FontWeight.w500,
                                ),
                              ),
                          Icon(Icons.lock, color: widget.currUserData.domainColor ?? colorScheme.primary,
                            size:14,
                          ),
                        ],
                      ): Container(),
                      specialPadding != 0 ? SizedBox(height:5):Container(),
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
                      SizedBox(height: 10),
                      Row(
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

                                ],
                              )),
                          SizedBox(width: 11),
                          Container(
                            padding: EdgeInsets.fromLTRB(10, 1, 10, 4),
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
                          SizedBox(width: 12),
                          Text(
                            convertTime(widget.post.createdAt.toDate()),
                            style: textTheme.headline6?.copyWith(fontSize: 17),
                          ),
                          widget.currUserData.userRef != widget.post.creatorRef
                              ? Row(
                            children: [
                              SizedBox(width: 10),
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
                      )
                    ], //Column Children ARRAY
                  ),
                ),
                Positioned(
                  left: 11,
                  top: 20+specialPadding,
                  child: buildGroupCircle(
                      groupImage: creatorImage, size: 30, context: context),
                ),
                Positioned(
                  right:3,
                  top: 10 + specialPadding,
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
        ],
      ),
    );
  }
}
