import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/commentView/commentCard.dart';
import 'package:hs_connect/screens/home/commentView/commentReplyForm.dart';
import 'package:hs_connect/screens/home/postView/Widgets/postTitleCard.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profilePostCard.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class profilePostFeed extends StatefulWidget {
  final DocumentReference profUserRef;

  profilePostFeed({Key? key, required this.profUserRef}) : super(key: key);

  @override
  _profilePostFeedState createState() => _profilePostFeedState();
}

class _profilePostFeedState extends State<profilePostFeed> {

  bool isReply=false;
  DocumentReference? commentRef;

  List<Post?>? _userPosts;

  @override
  void initState() {
    getUserPosts();
    CommentsDatabaseService _comments = CommentsDatabaseService(currUserRef: widget.profUserRef);

    super.initState();
  }

  void getUserPosts () async {
    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.profUserRef);
    _userPosts = await _posts.getUserPosts();
  }

  @override
  Widget build(BuildContext context) {

    switchFormBool(DocumentReference? passedRef){
      setState(() {
        isReply=!isReply;
        commentRef= passedRef;
      });
    }
    if (_userPosts == null) {
      return Text("No Posts");
    } else {
      return Container(
        width: MediaQuery.of(context).size.width*.9,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  SizedBox(width:10), Text("Your Posts", style: ThemeText.groupBold(fontSize: 24), textAlign: TextAlign.left),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width:10), Text("Visible to only you", style: ThemeText.regularSmall(fontSize: 16, color: ThemeColor.mediumGrey), textAlign: TextAlign.left),
                ],
              ),
              SizedBox(height: 20),
              Container(
              child:
              ListView.builder(
                itemCount: _userPosts?.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      profilePostCard(
                        post: _userPosts![index]!,
                        currUserRef: widget.profUserRef,
                      ),
                      SizedBox(height:10),
                    ],
                  );
                },
              ),
            ),
          ]
        ),
      );
    }
  }
}
