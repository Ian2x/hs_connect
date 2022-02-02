import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/screens/home/comments/likeDislikeComment.dart';
import 'package:hs_connect/screens/home/replies/replyFeed.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final DocumentReference currUserRef;
  final VoidDocParamFunction switchFormBool;

  CommentCard({
    Key? key,
    required this.switchFormBool,
    required this.comment,
    required this.currUserRef,
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
    if (widget.comment.likes.contains(widget.currUserRef)) {
      if (mounted) {
        setState(() {
          liked = true;
        });
      }
    } else if (widget.comment.likes.contains(widget.currUserRef)) {
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
      UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
      final UserData? fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.comment.creatorRef!);
      if (mounted) {
        setState(() {
          creatorName = fetchUserData != null ? fetchUserData.fundamentalName : null;
          creatorGroupName = fetchUserData != null ? (fetchUserData.fullDomainName!=null ? fetchUserData.fullDomainName : fetchUserData.domain) : null;
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

    final localCreatorName = creatorName!=null ? creatorName! : '';
    final localCreatorGroupName = creatorGroupName!=null ? creatorGroupName! : '';
    return Stack(
      children: [
        Positioned(
          top:-10*hp,
          right:3*wp,
          child:IconButton(icon: Icon(Icons.more_horiz),
            iconSize: 20*hp,
            color: colorScheme.primary,
            onPressed: (){
              showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20*hp),
                      )),
                  builder: (context) => pixelProvider(context, child: ReportSheet(
                    reportType: ReportType.comment,
                    entityRef: widget.comment.commentRef,
                  )));
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(18*wp, 10*hp, 13*wp, 0*hp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(localCreatorName + " • " + localCreatorGroupName,
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(color: creatorGroupColor !=null ? creatorGroupColor :colorScheme.primary)),
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
                                TextSpan(text: widget.comment.text,
                                    style: Theme.of(context).textTheme.bodyText1),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              convertTime(widget.comment.createdAt.toDate()), style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary)),
                            Spacer(),
                            TextButton(
                                child: Text("Reply", style: Theme.of(context).textTheme.bodyText2?.copyWith(color: colorScheme.secondary)),
                                onPressed: (){
                                  widget.switchFormBool(widget.comment.commentRef);
                                }
                            ),
                            widget.comment.creatorRef != null ? LikeDislikeComment(
                                comment: widget.comment,
                                currUserRef: widget.currUserRef,
                            ) : Container()
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          RepliesFeed(commentRef: widget.comment.commentRef, postRef: widget.comment.postRef, groupRef: widget.comment.groupRef),
          Divider(thickness: 3*hp, color: colorScheme.background, height: 3*hp),
            ]
          )
        ),

      ],
    );
  }
}
