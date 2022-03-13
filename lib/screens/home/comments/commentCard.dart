import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/screens/home/comments/likeDislikeComment.dart';
import 'package:hs_connect/screens/home/replies/replyFeed.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileSheet.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:provider/provider.dart';

import 'commentsFeed.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final UserData currUserData;
  final VoidOptionalCommentParamFunction switchFormBool;
  final VoidFunction focusKeyboard;
  final DocumentReference postCreatorRef;
  final Color? groupColor;
  final int index;

  CommentCard(
      {Key? key,
      required this.focusKeyboard,
      required this.switchFormBool,
      required this.comment,
      required this.currUserData,
      required this.postCreatorRef,
      required this.groupColor,
      required this.index})
      : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool liked = false;
  bool disliked = false;
  String? creatorName;
  Color? creatorGroupColor;
  String? creatorDomainName;
  int? creatorScore;

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.comment.likes.contains(widget.currUserData.userRef)) {
      liked = true;
    } else if (widget.comment.likes.contains(widget.currUserData.userRef)) {
      disliked = true;
    }
    getCreatorUserData();
    super.initState();
  }

  void getCreatorUserData() async {
    if (widget.comment.creatorRef != null) {
      UserDataDatabaseService _userDataDatabaseService =
          UserDataDatabaseService(currUserRef: widget.currUserData.userRef);
      final OtherUserData? fetchUserData =
          await _userDataDatabaseService.getOtherUserData(userRef: widget.comment.creatorRef!);
      if (mounted) {
        setState(() {
          creatorName = fetchUserData != null ? fetchUserData.fundamentalName : null;
          creatorScore = fetchUserData != null ? fetchUserData.score : null;
          creatorDomainName = fetchUserData != null ? (fetchUserData.fullDomainName ?? fetchUserData.domain) : null;
          creatorGroupColor = fetchUserData != null ? fetchUserData.domainColor : null;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          creatorName = '[Removed]';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final localCreatorName = creatorName ?? '';
    final localCreatorGroupName = creatorDomainName ?? '';
    return Consumer<ReplyToNotifier>(builder: (context, replyToNotifier, _) {
      return Column(
        children: [
          Container(
            color: replyToNotifier.commentIndex == widget.index ? colorScheme.background : null,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 33,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft),
                        onPressed: () {
                          if (creatorName != null && creatorScore != null && widget.comment.creatorRef != null) {
                            showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                )),
                                builder: (context) => ProfileSheet(
                                      currUserRef: widget.currUserData.userRef,
                                      otherUserScore: creatorScore!,
                                      otherUserFundName: localCreatorName,
                                      otherUserFullDomain: localCreatorGroupName,
                                      otherUserDomainColor: creatorGroupColor,
                                      otherUserRef: widget.comment.creatorRef!,
                                    ));
                          }
                        },
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: localCreatorName + " • ",
                                style: textTheme
                                    .subtitle2
                                    ?.copyWith(color: colorScheme.primary)),
                            TextSpan(
                                text: localCreatorGroupName,
                                style: textTheme.subtitle2?.copyWith(
                                    color: creatorGroupColor ?? colorScheme.primary))
                          ]),
                        )),
                  ),
                  Spacer(),
                  widget.comment.creatorRef == widget.postCreatorRef
                      ? Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.fromLTRB(10, 5, 0, 1),
                          margin: EdgeInsets.all(1),
                          child: Text('Creator',
                              style: textTheme
                                  .subtitle2
                                  ?.copyWith(color: widget.groupColor ?? colorScheme.onSurface)))
                      : Container(),
                ],
              ),
              SizedBox(height: 4),
              SizedBox(
                width: (MediaQuery.of(context).size.width) * .85,
                child: Text(widget.comment.text, style: textTheme.bodyText1?.copyWith(fontSize: 20)),
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Text(convertTime(widget.comment.createdAt.toDate()),
                      style: textTheme
                          .subtitle2
                          ?.copyWith(color: colorScheme.primary)),
                  SizedBox(width: 8),
                  widget.comment.creatorRef != null && widget.comment.creatorRef != widget.currUserData.userRef
                      ? Container(
                          height: 30,
                          child: IconButton(
                            icon: Icon(Icons.more_horiz, size: 20, color: colorScheme.primary),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  )),
                                  builder: (context) => ReportSheet(
                                        reportType: ReportType.comment,
                                        entityRef: widget.comment.commentRef,
                                        entityCreatorRef: widget.comment.creatorRef!,
                                      ));
                            },
                          ),
                        )
                      : Container(height: 30),
                  Spacer(),
                  Container(
                    height: 30,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory, padding: EdgeInsets.zero, alignment: Alignment.center),
                        child: Text("Reply",
                            style: textTheme.bodyText2?.copyWith(
                                fontSize: 15,
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600)),
                        onPressed: () {
                          replyToNotifier.setIndex(widget.index);
                          widget.focusKeyboard();
                          widget.switchFormBool(widget.comment);
                        }),
                  ),
                  widget.comment.creatorRef != null
                      ? LikeDislikeComment(
                          comment: widget.comment,
                          currUserRef: widget.currUserData.userRef,
                          currUserColor: widget.currUserData.domainColor,
                        )
                      : Container()
                ],
              ),
              SizedBox(height: 4),
              Divider(thickness: 3, color: colorScheme.background, height: 0),
            ]),
          ),
          RepliesFeed(
              commentRef: widget.comment.commentRef,
              groupColor: widget.groupColor,
              postCreatorRef: widget.postCreatorRef),
        ],
      );
    });
  }
}
