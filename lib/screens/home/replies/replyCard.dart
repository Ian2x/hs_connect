import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileSheet.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:provider/provider.dart';

import 'likeDislikeReply.dart';

class ReplyCard extends StatefulWidget {
  final Reply reply;
  final UserData currUserData;
  final DocumentReference postCreatorRef;

  ReplyCard({Key? key,
    required this.reply,
    required this.currUserData,
    required this.postCreatorRef}) : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  bool liked = false;
  bool disliked = false;
  String? replierName;
  String? replierGroupName;
  Color? replierGroupColor;
  int? replierScore;

  @override
  void initState() {
    super.initState();
    // initialize liked/disliked
    if (widget.reply.likes.contains(widget.currUserData.userRef)) {
      if (mounted) {
        setState(() {
          liked = true;
        });
      }
    } else if (widget.reply.likes.contains(widget.currUserData.userRef)) {
      if (mounted) {
        setState(() {
          disliked = true;
        });
      }
    }
    getUserData();
  }

  void getUserData() async {
    if (widget.reply.creatorRef != null) {
      UserDataDatabaseService _userInfoDatabaseService =
          UserDataDatabaseService(currUserRef: widget.currUserData.userRef);
      final UserData? fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.reply.creatorRef!);
      if (mounted) {
        setState(() {
          replierName = fetchUserData != null ? fetchUserData.fundamentalName : null;
          replierScore = fetchUserData != null ? fetchUserData.score : null;
          replierGroupName = fetchUserData != null
              ? (fetchUserData.fullDomainName != null ? fetchUserData.fullDomainName : fetchUserData.domain)
              : null;
          replierGroupColor = fetchUserData != null ? fetchUserData.domainColor : null;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          replierName = '[Removed]';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    final localCreatorName = replierName != null ? replierName! : '';
    final localCreatorGroupName = replierGroupName != null ? replierGroupName! : '';

    return Container(
        padding: EdgeInsets.fromLTRB(17 * wp, 0 * hp, 0 * wp, 0 * hp),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Divider(thickness: 3 * hp, color: colorScheme.background, height: 0 * hp),
          Row(
            children: [
              Container(
                height: 33 * hp,
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory, padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                    onPressed: () {
                      if (replierName != null) {
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20 * hp),
                                )),
                            builder: (context) => pixelProvider(context,
                                child: ProfileSheet(
                                  currUserRef: widget.currUserData.userRef,
                                  otherUserScore: replierScore!,
                                  otherUserFundName: localCreatorName,
                                  otherUserFullDomain: localCreatorGroupName,
                                  otherUserDomainColor: replierGroupColor,
                                  otherUserRef: widget.reply.creatorRef!,
                                )));
                      }
                    },
                  child: RichText(text: TextSpan(
                      children: [
                        TextSpan(
                            text: localCreatorName + " • ",
                            style: Theme.of(context).textTheme.subtitle2?.copyWith(
                                color: colorScheme.primaryVariant,
                                fontSize: commentReplyDetailSize,
                                fontWeight: FontWeight.w300)
                        ),
                        TextSpan(
                            text: localCreatorGroupName,
                            style: Theme.of(context).textTheme.subtitle2?.copyWith(
                                color: replierGroupColor != null ? replierGroupColor : colorScheme.primaryVariant,
                                fontSize: commentReplyDetailSize,
                                fontWeight: FontWeight.w300)
                        )
                      ]
                  ),
                  )
                ),
              ),
              Spacer(),
              widget.reply.creatorRef==widget.postCreatorRef
                  ? Container(
                padding: EdgeInsets.only(right: 10 * wp, top: 5 * hp),
                child: Container(
                    decoration: BoxDecoration(
                        color: replierGroupColor != null ? replierGroupColor : colorScheme.primary, borderRadius: BorderRadius.circular(17 * hp)),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17 * hp),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        padding: EdgeInsets.fromLTRB(10 * wp, 0* hp, 10 * wp, 1 * hp),
                        margin: EdgeInsets.all(1 * hp),
                        child: Text('Creator', style: Theme.of(context).textTheme.subtitle2?.copyWith(color: replierGroupColor != null ? replierGroupColor : colorScheme.primary, fontSize: 12)))),
              )
                  : Container(),
            ],
          ),
          SizedBox(height: 4*hp),
          SizedBox(
            width: (MediaQuery.of(context).size.width) * .85,
            child: Text(widget.reply.text,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600)),
          ),
          SizedBox(height: 7*hp),
          Row(
            children: [
              Text(convertTime(widget.reply.createdAt.toDate()),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      ?.copyWith(color: colorScheme.primary, fontSize: commentReplyDetailSize)),
              SizedBox(width: 8 * wp),
              widget.reply.creatorRef != null && widget.reply.creatorRef != widget.currUserData.userRef
                  ? Container(
                height: 30 * hp,
                child: IconButton(
                  icon: Icon(Icons.more_horiz, size: 20 * hp, color: colorScheme.primary),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20 * hp),
                        )),
                        builder: (context) => pixelProvider(context,
                            child: ReportSheet(
                              reportType: ReportType.reply,
                              entityRef: widget.reply.commentRef,
                              entityCreatorRef: widget.reply.creatorRef!,
                            )));
                  },
                ),
              ) : Container(height: 30 * hp),
              Spacer(),
              widget.reply.creatorRef != null
                  ? LikeDislikeReply(
                      reply: widget.reply,
                      currUserRef: widget.currUserData.userRef,
                      currUserColor: widget.currUserData.domainColor,
                    )
                  : Container()
            ],
          ),
          SizedBox(height: 4 * hp)
        ]));
  }
}
