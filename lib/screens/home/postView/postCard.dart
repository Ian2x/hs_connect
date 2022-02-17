import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/buildCircle.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/expandableImage.dart';
import 'package:hs_connect/shared/widgets/myLinkPreview.dart';
import 'package:provider/provider.dart';

const postCardDetailSize = 12.0;

class PostCard extends StatefulWidget {
  final Post post;
  final UserData currUser;

  PostCard({Key? key, required this.post, required this.currUser}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin<PostCard> {
  static const leftRightMargin = 10.0;

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
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
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
              builder: (context) => pixelProvider(context,
                  child: PostPage(
                      post: widget.post,
                      group: group!,
                      creatorData: fetchUserData!,
                      postLikesManager: postLikesManager))),
        );
      },
      child: Card(
          //if border then ShapeDecoration
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * hp)),
          margin: EdgeInsets.fromLTRB(leftRightMargin, 4 * hp, leftRightMargin, 4 * hp),
          elevation: 0,
          child: Container(
              padding: EdgeInsets.fromLTRB(0, 10 * hp, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10 * wp),
                      buildGroupCircle(
                          groupImage: group != null ? group!.image : null,
                          height: 24 * hp,
                          width: 24 * hp,
                          context: context,
                          backgroundColor: colorScheme.surface),
                      SizedBox(width: 5 * wp),
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
                              padding: EdgeInsets.only(right: 10 * wp, top: 0 * hp),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: colorScheme.primary, borderRadius: BorderRadius.circular(17 * hp)),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(17 * hp),
                                        color: Theme.of(context).colorScheme.surface,
                                      ),
                                      padding: EdgeInsets.fromLTRB(14 * wp, 2* hp, 14 * wp, 3 * hp),
                                      margin: EdgeInsets.all(1.5 * hp),
                                      child: Text('Mature', style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary, fontSize: 12)))),
                            )
                          : Container(),
                      widget.post.isFeatured
                          ? Container(
                              padding: EdgeInsets.only(right: 10 * wp, top: 0 * hp),
                              child: Container(
                                  decoration: BoxDecoration(
                                      gradient: Gradients.blueRed(), borderRadius: BorderRadius.circular(17 * hp)),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(17 * hp),
                                        color: Theme.of(context).colorScheme.surface,
                                      ),
                                      padding: EdgeInsets.fromLTRB(14 * wp, 2 * hp, 14 * wp, 3 * hp),
                                      margin: EdgeInsets.all(1.5 * hp),
                                      child: Text('Featured', style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: 12)))),
                            )
                          : Container(),
                    ],
                  ),
                  SizedBox(height: 10 * hp),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10 * wp),
                    child: Text(widget.post.title,
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                              fontSize: 16 * hp,
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis, // default is .clip
                        maxLines: 3),
                  ),
                  widget.post.link != null ? Container(
                    margin: EdgeInsets.only(top: 10 * hp),
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
                          maxHeight: 300 * hp,
                          loadingHeight: 300 * hp,
                          margin: EdgeInsets.only(top: 10 * hp))
                      : Container(),
                  poll != null
                      ? Container(
                          alignment: Alignment.center,
                          child: PollView(poll: poll!, currUserRef: widget.currUser.userRef, post: widget.post))
                      : Container(),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 2 * hp),
                    child: Row(
                      //Icon Row
                      children: [
                        SizedBox(width: 10 * wp),
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
                                            entityCreatorRef: widget.post.creatorRef,
                                          )));
                                },
                              )
                            : Container(height: 38 * hp),
                        Spacer(),
                        fetchUserData != null && fetchUserData!.userRef != widget.currUser.userRef
                            ? DMButton(currUserRef: widget.currUser.userRef,
                              otherUserRef: fetchUserData!.userRef,
                              otherUserFundName: fetchUserData!.fundamentalName,
                            )
                            : Container(),
                        LikeDislikePost(
                            currUserRef: widget.currUser.userRef,
                            post: widget.post,
                            postLikesManager: postLikesManager),
                        SizedBox(width: 10 * wp),
                      ],
                    ),
                  )
                ], //Column Children ARRAY
              ))),
    );
  }
}
