import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/screens/home/comments/likeDislikeComment.dart';
import 'package:hs_connect/screens/home/replies/replyFeed.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
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
  String username = '';
  String? imageString;
  Image? userImage;
  Color? groupColor;
  String userGroupName='';

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
          username = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
          userGroupName = fetchUserData != null ? fetchUserData.domain : '<Failed to retrieve user name>';
          imageString = fetchUserData != null ? fetchUserData.profileImageURL : '<Failed to retrieve user name>';
          groupColor = fetchUserData != null ? fetchUserData.domainColor :ThemeColor.black;
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
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    
    return Stack(
      children: [
        Positioned(
          top:-10*hp,
          right:0*wp,
          child:IconButton(icon: Icon(Icons.more_horiz),
            iconSize: 20*hp,
            onPressed: (){
              showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20*hp),
                      )),
                  builder: (context) => new ReportSheet(
                    reportType: ReportType.comment,
                    entityRef: widget.comment.commentRef,
                  ));
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20*wp, 5*hp, 10*wp, 0*hp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(username + " • " + userGroupName,
                  style: ThemeText.groupBold(color: groupColor !=null ? groupColor :ThemeColor.mediumGrey,
                      fontSize: 13*hp)),
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
                                    style: ThemeText.postViewText(color: ThemeColor.black, fontSize: 14*hp, height: 1.5)),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              convertTime(widget.comment.createdAt.toDate()), style: ThemeText.groupBold(color: ThemeColor.mediumGrey, fontSize:14*hp),
                            ),
                            Spacer(flex:1),
                            TextButton(
                                child: Text("Reply", style: ThemeText.groupBold(color: ThemeColor.secondaryBlue, fontSize:15*hp)),
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
          Divider(thickness: 3*hp, color: ThemeColor.backgroundGrey, height: 20*hp),
            ]
          )
        ),

      ],
    );
  }
}
