import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profilePage.dart';
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
  final bool isLast;

  ReplyCard({Key? key, required this.isLast, required this.reply, required this.currUserData}) : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  bool liked = false;
  bool disliked = false;
  String? creatorName;
  String? creatorGroupName;
  Color? groupColor;

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
          creatorName = fetchUserData != null ? fetchUserData.fundamentalName : null;
          creatorGroupName = fetchUserData != null
              ? (fetchUserData.fullDomainName != null ? fetchUserData.fullDomainName : fetchUserData.domain)
              : null;
          groupColor = fetchUserData != null ? fetchUserData.domainColor : null;
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
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    final localCreatorName = creatorName != null ? creatorName! : '';
    final localCreatorGroupName = creatorGroupName != null ? creatorGroupName! : '';

    return Container(
        padding: EdgeInsets.fromLTRB(17 * wp, 0 * hp, 0 * wp, 0 * hp),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Divider(thickness: 3 * hp, color: colorScheme.background, height: 0 * hp),
          Container(
            height: 33 * hp,
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory, padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => pixelProvider(context,
                          child: ProfilePage(profileRef: widget.reply.creatorRef!, currUserData: widget.currUserData))),
                );
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
                            color: groupColor != null ? groupColor : colorScheme.primaryVariant,
                            fontSize: commentReplyDetailSize,
                            fontWeight: FontWeight.w300)
                    )
                  ]
              ),
              )
            ),
          ),
          SizedBox(height: 4*hp),
          SizedBox(
            width: (MediaQuery.of(context).size.width) * .85,
            child: Text(widget.reply.text,
                style: Theme.of(context).textTheme.bodyText1),
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
              Container(
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
                            )));
                  },
                ),
              ),
              Spacer(),
              widget.reply.creatorRef != null
                  ? LikeDislikeReply(
                      reply: widget.reply,
                      currUserRef: widget.currUserData.userRef,
                    )
                  : Container()
            ],
          ),
          SizedBox(height: 4 * hp)
        ]));
  }
}
