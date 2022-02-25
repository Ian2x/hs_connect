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

class PostCard extends StatefulWidget {
  final Post post;
  final UserData currUser;

  PostCard({Key? key, required this.post, required this.currUser}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin<PostCard> {
  static const leftRightMargin = 8.0;

  @override
  bool get wantKeepAlive => true;

  String? username;
  Group? group;
  late bool likeStatus;
  late bool dislikeStatus;
  late int likeCount;
  late int dislikeCount;
  UserData? fetchUserData;
  Poll? poll;

  @override
  void initState() {
    likeStatus = widget.post.likes.contains(widget.currUser.userRef);
    dislikeStatus = widget.post.dislikes.contains(widget.currUser.userRef);
    likeCount = widget.post.likes.length;
    dislikeCount = widget.post.dislikes.length;
    getUserData();
    getGroupData();
    getPoll();
    super.initState();
  }

  void getUserData() async {
    UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUser.userRef);
    fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.post.creatorRef, noDomainData: true);
    if (mounted) {
      setState(() {
        username = fetchUserData != null ? fetchUserData!.displayedName : null;
      });
    }
  }

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUser.userRef);
    final Group? fetchGroup = await _groups.groupFromRef(widget.post.groupRef);
    if (fetchGroup != null) {
      if (mounted) {
        setState(() {
          group = fetchGroup;
        });
      }
    }
  }

  void getPoll() async {
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

    if (group == null || username == null) {
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostPage(
                      post: widget.post,
                      group: group!,
                      creatorData: fetchUserData!,
                      postLikesManager: postLikesManager)),
        );
      },
      child: Card(
          //if border then ShapeDecoration
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: widget.post.isFeatured ? (widget.currUser.domainColor!=null ? widget.currUser.domainColor! : colorScheme.primary) : Colors.transparent, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.fromLTRB(leftRightMargin, 4, leftRightMargin, 4),
          elevation: 0,
          child: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10),
                      buildGroupCircle(
                          groupImage: group != null ? group!.image : null,
                          size: 21,
                          context: context,
                          backgroundColor: colorScheme.surface),
                      SizedBox(width: 5),
                      Text(
                        group!.name,
                        style: Theme.of(context).textTheme.subtitle2?.copyWith(
                            color: group!.hexColor != null ? HexColor(group!.hexColor!) : colorScheme.primary,
                            fontSize: postCardDetailSize),
                      ),
                      Text(
                        " • " + convertTime(widget.post.createdAt.toDate()),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            ?.copyWith(color: colorScheme.primary, fontSize: postCardDetailSize),
                      ),
                      Spacer(),
                      widget.post.mature && !widget.post.isFeatured
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              padding: EdgeInsets.fromLTRB(14, 2, 14, 3),
                              margin: EdgeInsets.all(1.5),
                              child: Text('Mature', style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary, fontSize: 12)))
                          : Container(),
                      widget.post.isFeatured
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              padding: EdgeInsets.fromLTRB(14, 2, 14, 3),
                              margin: EdgeInsets.all(1.5),
                              child: Text('Trending', style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: 12, color: widget.currUser.domainColor != null ? widget.currUser.domainColor : colorScheme.primary)))
                          : Container(),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(widget.post.title,
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis, // default is .clip
                        maxLines: 3),
                  ),
                  widget.post.link != null ? Container(
                    margin: EdgeInsets.only(top: 10),
                    child: MyLinkPreview(
                      enableAnimation: true,
                      onPreviewDataFetched: (data) {
                        setState(() => previewData = data);
                      },
                      metadataTitleStyle: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold),
                      metadataTextStyle: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 14),
                      previewData: previewData,
                      text: widget.post.link!,
                      textStyle: Theme.of(context).textTheme.subtitle2,
                      linkStyle: Theme.of(context).textTheme.subtitle2,
                      width: MediaQuery.of(context).size.width - 2 * leftRightMargin,
                    ),
                  ) : Container(),
                  widget.post.mediaURL != null
                      ? ExpandableImage(
                          imageURL: widget.post.mediaURL!,
                          containerWidth: MediaQuery.of(context).size.width - 2 * leftRightMargin,
                          maxHeight: 300,
                          loadingHeight: 300,
                          margin: EdgeInsets.only(top: 10))
                      : Container(),
                  poll != null
                      ? Container(
                          alignment: Alignment.center,
                          child: PollView(poll: poll!, currUserRef: widget.currUser.userRef, post: widget.post))
                      : Container(),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                    child: Row(
                      //Icon Row
                      children: [
                        SizedBox(width: 10),
                        Text(
                          (widget.post.numComments + widget.post.numReplies).toString() + " Comments",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              ?.copyWith(color: colorScheme.primary, fontSize: postCardDetailSize),
                        ),
                        widget.currUser.userRef != widget.post.creatorRef
                            ? IconButton(
                                constraints: BoxConstraints(),
                                splashRadius: .1,
                                icon: Icon(Icons.more_horiz, size: 20, color: colorScheme.primary),
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
                            : Container(height: 38),
                        fetchUserData != null && fetchUserData!.userRef != widget.currUser.userRef
                            ? DMButton(currUserRef: widget.currUser.userRef,
                          otherUserRef: fetchUserData!.userRef,
                          otherUserFundName: fetchUserData!.fundamentalName,
                        )
                            : Container(),
                        Spacer(),
                        LikeDislikePost(
                            currUserRef: widget.currUser.userRef,
                            post: widget.post,
                            postLikesManager: postLikesManager,
                            currUserColor: widget.currUser.domainColor,
                        ),
                        SizedBox(width: 1),
                      ],
                    ),
                  )
                ], //Column Children ARRAY
              ))),
    );
  }
}
