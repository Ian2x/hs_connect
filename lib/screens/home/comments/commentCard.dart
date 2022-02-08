import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/screens/home/comments/likeDislikeComment.dart';
import 'package:hs_connect/screens/home/replies/replyFeed.dart';
import 'package:hs_connect/screens/profile/profilePage.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final UserData currUserData;
  final VoidDocParamFunction switchFormBool;
  final VoidFunction focusKeyboard;

  CommentCard({
    Key? key,
    required this.focusKeyboard,
    required this.switchFormBool,
    required this.comment,
    required this.currUserData,
  }) : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool liked = false;
  bool disliked = false;
  String? creatorName;
  Color? creatorGroupColor;
  String? creatorGroupName;

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.comment.likes.contains(widget.currUserData.userRef)) {
      if (mounted) {
        setState(() {
          liked = true;
        });
      }
    } else if (widget.comment.likes.contains(widget.currUserData.userRef)) {
      if (mounted) {
        setState(() {
          disliked = true;
        });
      }
    }
    getUserData();
    super.initState();
  }

  void getUserData() async {
    if (widget.comment.creatorRef != null) {
      UserDataDatabaseService _userDataDatabaseService =
          UserDataDatabaseService(currUserRef: widget.currUserData.userRef);
      final UserData? fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.comment.creatorRef!);
      if (mounted) {
        setState(() {
          creatorName = fetchUserData != null ? fetchUserData.fundamentalName : null;
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
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    final localCreatorName = creatorName != null ? creatorName! : '';
    final localCreatorGroupName = creatorGroupName != null ? creatorGroupName! : '';
    return Container(
        padding: EdgeInsets.fromLTRB(17 * wp, 0 * hp, 17 * wp, 0 * hp),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            height: 33 * hp,
            child: TextButton(
              style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory, padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => pixelProvider(context,
                          child:
                              ProfilePage(profileRef: widget.comment.creatorRef!, currUserData: widget.currUserData))),
                );
              },
              child: Text(localCreatorName + " • " + localCreatorGroupName,
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(
                      color: creatorGroupColor != null ? creatorGroupColor : colorScheme.primaryVariant,
                      fontSize: commentReplyDetailSize,
                      fontWeight: FontWeight.w300)),
            ),
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width) * .85,
            child: Text(widget.comment.text,
                style: Theme.of(context).textTheme.bodyText1),
          ),
          Row(
            children: [
              Text(convertTime(widget.comment.createdAt.toDate()),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      ?.copyWith(color: colorScheme.primary, fontSize: commentReplyDetailSize)),
              SizedBox(width: 8 * wp),
              Container(
                height: 20*hp,
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
                              reportType: ReportType.comment,
                              entityRef: widget.comment.commentRef,
                            )));
                  },
                ),
              ),
              Spacer(),
              Container(
                height: 30*hp,
                child: TextButton(
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        padding: EdgeInsets.zero,
                        alignment: Alignment.center),
                    child: Text("Reply",
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: commentReplyDetailSize)),
                    onPressed: () {
                      widget.focusKeyboard();
                      widget.switchFormBool(widget.comment.commentRef);
                    }),
              ),
              widget.comment.creatorRef != null
                  ? LikeDislikeComment(
                      comment: widget.comment,
                      currUserRef: widget.currUserData.userRef,
                    )
                  : Container()
            ],
          ),
          SizedBox(height: 4*hp),
          RepliesFeed(
              commentRef: widget.comment.commentRef,
              postRef: widget.comment.postRef,
              groupRef: widget.comment.groupRef),
          Divider(thickness: 3 * hp, color: colorScheme.background, height: 0),
        ]));
  }
}
