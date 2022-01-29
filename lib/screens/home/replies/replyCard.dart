import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:provider/provider.dart';

import 'likeDislikeReply.dart';

class ReplyCard extends StatefulWidget {
  final Reply reply;
  final DocumentReference currUserRef;
  final bool isLast;

  ReplyCard(
      {Key? key,
      required this.isLast,
      required this.reply,
      required this.currUserRef})
      : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {

  bool liked = false;
  bool disliked = false;
  String username="";
  String groupName="";
  Color? groupColor;


  @override
  void initState() {
    super.initState();
    // initialize liked/disliked
    if (widget.reply.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          liked = true;
        });
      }
    } else if (widget.reply.likes.contains(widget.currUserRef)) {
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
      UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
      final UserData? fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.reply.creatorRef!);
      if (mounted) {
        setState(() {
          username = fetchUserData != null ? fetchUserData.fundamentalName : '<Failed to retrieve user name>';
          groupColor = fetchUserData != null ? fetchUserData.domainColor : null;
          groupName = fetchUserData != null ? fetchUserData.domain : '<Failed to retrieve user name>';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          username = '[Removed]';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          top:-10*hp,
          right:-10*wp,
          child:IconButton(icon: Icon(Icons.more_horiz),
            iconSize: 20*hp,
            onPressed: (){
              showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20*hp),
                      )),
                  builder: (context) => pixelProvider(context, child: ReportSheet(
                    reportType: ReportType.reply,
                    entityRef: widget.reply.replyRef,
                  )));

            },
          ),
        ),
        Container(
            padding: EdgeInsets.fromLTRB(20*wp, 5*hp, 0, 5*hp),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(username + " • " + groupName,
                      style: Theme.of(context).textTheme.subtitle2?.copyWith(color: groupColor != null ? groupColor: colorScheme.primary, fontSize: 13*hp)),
                  SizedBox(height:10*hp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        fit:FlexFit.loose,
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
                                  convertTime(widget.reply.createdAt.toDate()), style: Theme.of(context).textTheme.bodyText2),
                                Spacer(flex:1),
                                widget.reply.creatorRef != null ? LikeDislikeReply(
                                    reply: widget.reply,
                                    currUserRef: widget.currUserRef,
                                ) : Container()
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  widget.isLast !=false ?
                    Container() :
                    Divider(thickness: 3*hp, color: colorScheme.background, height: 40*hp),
                ]
            )
        ),
      ],
    );
  }
}
