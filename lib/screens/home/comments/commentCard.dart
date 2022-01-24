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
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/reportSheet.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final DocumentReference currUserRef;
  final VoidDocParamFunction switchFormBool;
  final double hp;
  final double wp;

  CommentCard({
    Key? key,
    required this.switchFormBool,
    required this.comment,
    required this.currUserRef,
    required this.hp,
    required this.wp,
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
  double? hp;
  double? wp;

  @override
  void initState() {
    if (mounted) {
      setState(() {
        wp = widget.wp;
        hp = widget.hp;
      });
    }
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

    if (wp==null || hp == null) return Loading();

    return Stack(
      children: [
        Positioned(
          top:-10*hp!,
          right:0,
          child:IconButton(icon: Icon(Icons.more_horiz),
            iconSize: 20,
            onPressed: (){
              showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      )),
                  builder: (context) => new ReportSheet(
                    reportType: ReportType.comment,
                    entityRef: widget.comment.commentRef,
                  ));
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20.0, 5, 10.0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(username + " • " + userGroupName,
                  style: ThemeText.groupBold(color: groupColor !=null ? groupColor :ThemeColor.mediumGrey,
                      fontSize: 13)),
              SizedBox(height:10),
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
                                    style: ThemeText.postViewText(color: ThemeColor.black, fontSize: 14, height: 1.5)),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              convertTime(widget.comment.createdAt.toDate()), style: ThemeText.groupBold(color: ThemeColor.mediumGrey, fontSize:14),
                            ),
                            Spacer(flex:1),
                            TextButton(
                                child: Text("Reply", style: ThemeText.groupBold(color: ThemeColor.secondaryBlue, fontSize:15)),
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
          Divider(thickness: 3, color: ThemeColor.backgroundGrey, height: 20),
            ]
          )
        ),

      ],
    );
  }
}
