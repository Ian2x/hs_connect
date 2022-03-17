import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileSheet.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';

import 'likeDislikeReply.dart';

class ReplyCard extends StatefulWidget {
  final Reply reply;
  final UserData currUserData;
  final DocumentReference postCreatorRef;
  final Color? groupColor;

  ReplyCard(
      {Key? key,
      required this.reply,
      required this.currUserData,
      required this.postCreatorRef,
      required this.groupColor})
      : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  bool liked = false;
  bool disliked = false;
  String? creatorName;
  String? creatorGroupName;
  Color? creatorGroupColor;
  int? creatorScore;

  @override
  void initState() {
    super.initState();
    // initialize liked/disliked
    if (widget.reply.likes.contains(widget.currUserData.userRef)) {
      liked = true;
    } else if (widget.reply.likes.contains(widget.currUserData.userRef)) {
      disliked = true;
    }
    getOtherUserData();
  }

  void getOtherUserData() async {
    if (widget.reply.creatorRef != null) {
      UserDataDatabaseService _userInfoDatabaseService =
          UserDataDatabaseService(currUserRef: widget.currUserData.userRef);
      final OtherUserData? fetchUserData =
          await _userInfoDatabaseService.getOtherUserData(userRef: widget.reply.creatorRef!);
      if (mounted) {
        setState(() {
          creatorName = fetchUserData != null ? fetchUserData.fundamentalName : null;
          creatorScore = fetchUserData != null ? fetchUserData.score : null;
          creatorGroupName = fetchUserData != null
              ? (fetchUserData.fullDomainName != null ? fetchUserData.fullDomainName : fetchUserData.domain)
              : null;
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
    final localCreatorGroupName = creatorGroupName ?? '';

    return Container(
        color: colorScheme.surface,
        padding: EdgeInsets.only(left: 30, right: 15),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(
            children: [
              Container(
                height: 33,
                alignment: Alignment.centerLeft,
                child: TextButton(
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft),
                    onPressed: () {
                      if (creatorName != null) {
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
                                  otherUserRef: widget.reply.creatorRef!,
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
              widget.reply.creatorRef == widget.postCreatorRef
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      padding: EdgeInsets.fromLTRB(10, 5, 0, 1),
                      margin: EdgeInsets.all(1),
                      child: Text('Creator',
                          style: textTheme.subtitle2?.copyWith(
                              color: widget.groupColor ?? colorScheme.onSurface)))
                  : Container(),
            ],
          ),
          SizedBox(height: 4),
          SizedBox(
            width: (MediaQuery.of(context).size.width) * .85,
            child: Text(widget.reply.text, style: textTheme.bodyText1?.copyWith(fontSize: 18)),
          ),
          SizedBox(height: 7),
          Row(
            children: [
              Text(convertTime(widget.reply.createdAt.toDate()),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      ?.copyWith(color: colorScheme.primary)),
              SizedBox(width: 8),
              widget.reply.creatorRef != null && widget.reply.creatorRef != widget.currUserData.userRef
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
                                    reportType: ReportType.reply,
                                    entityRef: widget.reply.commentRef,
                                    entityCreatorRef: widget.reply.creatorRef!,
                                  ));
                        },
                      ),
                    )
                  : Container(height: 30),
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
          SizedBox(height: 4),
          Divider(thickness: 3, color: colorScheme.background, height: 0),
        ]));
  }
}
