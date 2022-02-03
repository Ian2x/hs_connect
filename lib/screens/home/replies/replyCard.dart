import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profilePage.dart';
import 'package:hs_connect/services/user_data_database.dart';
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

  ReplyCard(
      {Key? key,
      required this.isLast,
      required this.reply,
      required this.currUserData})
      : super(key: key);

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
    // find username for userId
    // _userInfoDatabaseService.userId = widget.userId;
    getUserData();
  }

  void getUserData() async {
    if (widget.reply.creatorRef != null) {
      UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserData.userRef);
      final UserData? fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.reply.creatorRef!);
      if (mounted) {
        setState(() {
          creatorName = fetchUserData != null ? fetchUserData.fundamentalName : null;
          creatorGroupName = fetchUserData != null ? (fetchUserData.fullDomainName!=null ? fetchUserData.fullDomainName : fetchUserData.domain) : null;
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

    final localCreatorName = creatorName!=null ? creatorName! : '';
    final localCreatorGroupName = creatorGroupName!=null ? creatorGroupName! : '';

    return Stack(
      children: [
        Container(
            margin:EdgeInsets.zero,
            padding: EdgeInsets.fromLTRB(20*wp, 0*hp, 0*wp, 0*hp),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Divider(thickness: 3*hp, color: colorScheme.background, height: 3*hp),
                  TextButton(
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                pixelProvider(context,
                                    child: ProfilePage(profileRef:widget.reply.creatorRef!,currUserData: widget.currUserData)
                                )),
                      );
                    },
                    child:
                    Text(localCreatorName + " • " + localCreatorGroupName,
                        style: Theme.of(context).textTheme.subtitle2?.copyWith
                          (color: groupColor != null ? groupColor: colorScheme.primaryVariant, fontSize: 13*hp)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        fit:FlexFit.tight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: (MediaQuery.of(context).size.width)*.85,
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(text: widget.reply.text,
                                        style: Theme.of(context).textTheme.bodyText1),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                    convertTime(widget.reply.createdAt.toDate()),
                                    style: Theme.of(context).textTheme.subtitle2?.
                                    copyWith(color: colorScheme.primary)),
                                SizedBox(width:8*wp),
                                TextButton(
                                  child: Icon(Icons.more_horiz, size:20*hp, color: colorScheme.primary),
                                  style: TextButton.styleFrom(
                                      splashFactory: NoSplash.splashFactory,
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.centerLeft),
                                  onPressed: (){
                                    showModalBottomSheet(
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20*hp),
                                            )),
                                        builder: (context) => pixelProvider(context, child: ReportSheet(
                                          reportType: ReportType.reply,
                                          entityRef: widget.reply.commentRef,
                                        )));
                                  },
                                ),
                                Spacer(),
                                widget.reply.creatorRef != null ? LikeDislikeReply(
                                    reply: widget.reply,
                                    currUserRef: widget.currUserData.userRef,
                                ) : Container()
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  widget.isLast !=false ?
                    Container():
                    Divider(thickness: 3*hp, color: colorScheme.background, height: 30*hp),
                ]
            )
        ),
      ],
    );
  }
}
