import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/poll.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/likeDislikePost.dart';
import 'package:hs_connect/screens/home/postView/pollView.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileSheet.dart';
import 'package:hs_connect/services/polls_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/expandableImage.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:hs_connect/shared/widgets/myLinkPreview.dart';
import 'package:provider/provider.dart';

class PostTitleCard extends StatefulWidget {
  final Post post;
  final Group group;
  final UserData currUserData;

  PostTitleCard({
    Key? key,
    required this.post,
    required this.group,
    required this.currUserData,
  }) : super(key: key);

  @override
  _PostTitleCardState createState() => _PostTitleCardState();
}

class _PostTitleCardState extends State<PostTitleCard> {
  String? creatorName;
  String? creatorGroup;
  Color? creatorColor;
  Poll? poll;
  OtherUserData? fetchUserData;

  @override
  void initState() {
    // find username for userId
    getPostCreatorData();
    getPoll();
    super.initState();
  }

  void getPostCreatorData() async {
    UserDataDatabaseService _userDataDatabaseService =
        UserDataDatabaseService(currUserRef: widget.currUserData.userRef);
    fetchUserData = await _userDataDatabaseService.getOtherUserData(userRef: widget.post.creatorRef);
    if (mounted) {
      setState(() {
        creatorName = fetchUserData != null ? fetchUserData!.fundamentalName : null;
        creatorGroup = fetchUserData != null
            ? (fetchUserData!.fullDomainName ?? fetchUserData!.domain)
            : null;
        creatorColor = fetchUserData != null ? fetchUserData!.domainColor : null;
      });
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

  PreviewData? previewData;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    PostLikesManager postLikesManager = Provider.of<PostLikesManager>(context);
    final leftRightPadding = 15.0;

    final localCreatorName = creatorName ?? '';
    final localCreatorGroup = creatorGroup ?? '';

    return Container(
      padding: EdgeInsets.fromLTRB(leftRightPadding, 0, leftRightPadding, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(//intro row + three dots
              children: [
            GestureDetector(
                onTap: () {
                  if (fetchUserData != null) {
                    showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        )),
                        builder: (context) => ProfileSheet(
                              currUserRef: widget.currUserData.userRef,
                              otherUserFullDomain: fetchUserData!.fullDomainName!,
                              otherUserRef: fetchUserData!.userRef,
                              otherUserDomainColor: fetchUserData!.domainColor,
                              otherUserFundName: fetchUserData!.fundamentalName,
                              otherUserScore: fetchUserData!.score,
                            ));
                  }
                },
                child: RichText(
                  text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(color: colorScheme.primary, fontSize: postCardDetailSize + 1),
                      children: [
                        TextSpan(text: "from " + localCreatorName + " • "),
                        TextSpan(
                            style: Theme.of(context).textTheme.subtitle2?.copyWith(
                                color: creatorColor ?? colorScheme.primary,
                                fontSize: postCardDetailSize + 1),
                            text: localCreatorGroup),
                        TextSpan(text: " • " + convertTime(widget.post.createdAt.toDate()))
                      ]),
                )),
            Spacer(),
            widget.post.mature
                ? Text(
                    "Mature",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        ?.copyWith(color: colorScheme.primary, fontSize: postCardDetailSize + 1),
                  )
                : Container(),
            widget.post.creatorRef != widget.currUserData.userRef
                ? IconButton(
                    icon: Icon(Icons.more_horiz),
                    iconSize: 20,
                    color: colorScheme.primary,
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
                : Container(height: 48)
          ]), //introRow
          SelectableLinkify(
              text: widget.post.title,
              onOpen: openLink,
              style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18)),
          SizedBox(height: 12),
          widget.post.text != null && widget.post.text != ""
              ? SelectableLinkify(
                  text: widget.post.text!,
                  onOpen: openLink,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 16, height: 1.3),
                )
              : Container(),
          widget.post.link != null
              ? Container(
                  margin: EdgeInsets.only(top: 10),
                  child: MyLinkPreview(
                    enableAnimation: true,
                    onPreviewDataFetched: (data) {
                      if (mounted) {
                        setState(() => previewData = data);
                      }
                    },
                    metadataTitleStyle: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold),
                    metadataTextStyle: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 14),
                    previewData: previewData,
                    text: widget.post.link!,
                    textStyle: Theme.of(context).textTheme.subtitle2,
                    linkStyle: Theme.of(context).textTheme.subtitle2,
                    width: MediaQuery.of(context).size.width - 2 * leftRightPadding,
                  ),
                )
              : Container(),
          widget.post.mediaURL != null
              ? Container(
                  margin: EdgeInsets.only(top: 10),
                  child: ExpandableImage(
                      imageURL: widget.post.mediaURL!,
                      maxHeight: 450,
                      containerWidth: MediaQuery.of(context).size.width - 2 * leftRightPadding),
                )
              : Container(),
          poll != null
              ? PollView(poll: poll!, currUserRef: widget.currUserData.userRef, post: widget.post)
              : Container(),
          SizedBox(height: 17),
          Row(
            children: [
              Text(
                widget.post.numComments + widget.post.numReplies < 2
                    ? 'Comments'
                    : (widget.post.numComments + widget.post.numReplies).toString() + ' Comments',
                style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 16),
              ),
              Spacer(),
              LikeDislikePostStateful(
                currUserRef: widget.currUserData.userRef,
                post: widget.post,
                postLikesManager: postLikesManager,
                currUserColor: widget.currUserData.domainColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
