import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/post_feeds/specific_group_feed.dart';
import 'package:hs_connect/screens/home/post_view/delete_post.dart';
import 'package:hs_connect/screens/home/post_view/like_dislike_post.dart';
import 'package:hs_connect/screens/home/post_view/post_page.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final DocumentReference postRef;
  final DocumentReference userRef;
  final DocumentReference groupRef;
  final String title;
  final String text;
  final String? media;
  final Timestamp createdAt;
  List<DocumentReference> likes;
  List<DocumentReference> dislikes;
  int numComments;
  final DocumentReference currUserRef;
  final Report? reportedStatus;
  final List<String> tags;

  PostCard(
      {Key? key,
      required this.postRef,
      required this.userRef,
      required this.groupRef,
      required this.title,
      required this.text,
      required this.media,
      required this.createdAt,
      required this.likes,
      required this.dislikes,
      required this.numComments,
      required this.currUserRef,
      required this.reportedStatus,
      required this.tags})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService();

  GroupsDatabaseService _groups = GroupsDatabaseService();

  PostsDatabaseService _posts = PostsDatabaseService();

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';
  String groupName = '<Loading group name...>';
  Image groupImage =
      Image(image: AssetImage('assets/masonic-G.png'), height: 20, width: 20);

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.likes.contains(widget.currUserRef)) {
      setState(() {
        liked = true;
      });
    } else if (widget.dislikes.contains(widget.currUserRef)) {
      setState(() {
        disliked = true;
      });
    }
    getUsername();
    getGroupName();
    super.initState();
  }

  void getUsername() async {
    final UserData? fetchUsername =
        await _userInfoDatabaseService.getUserData(userRef: widget.userRef);
    setState(() {
      username = fetchUsername != null
          ? fetchUsername.displayedName
          : '<Failed to retrieve user name>';
    });
  }

  void getGroupName() async {
    final Group? fetchGroupName =
        await _groups.getGroupData(groupRef: widget.groupRef);
    setState(() {
      groupName = fetchGroupName != null
          ? fetchGroupName.name
          : '<Failed to retrieve group name>';
    });
  }

  void openSpecificGroupFeed() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SpecificGroupFeed(
                groupRef: widget.groupRef,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
        elevation: 0.3,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Dismissible(
            key: ValueKey(widget.postRef),
            child: ListTile(
              title: Row(children: <Widget>[
                IconButton(
                  icon: groupImage,
                  onPressed: openSpecificGroupFeed,
                ),
                Text(widget.title),
              ]),
              subtitle: Column(children: <Widget>[
                Text(username +
                    ' in ' +
                    groupName +
                    '      ' +
                    timeago.format(widget.createdAt.toDate())),
                widget.media != null
                    ? Image.network(widget.media!)
                    : Container(),
                Row(children: <Widget>[
                  Text(widget.numComments.toString()),
                  LikeDislikePost(
                      currUserRef: widget.currUserRef,
                      postRef: widget.postRef,
                      likes: widget.likes,
                      dislikes: widget.dislikes),
                ])
              ]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PostPage(
                              postInfo: Post(
                            postRef: widget.postRef,
                            userRef: widget.userRef,
                            groupRef: widget.groupRef,
                            title: widget.title,
                            text: widget.text,
                            media: widget.media,
                            createdAt: widget.createdAt,
                            likes: widget.likes,
                            dislikes: widget.dislikes,
                            numComments: widget.numComments,
                            reportedStatus: widget.reportedStatus,
                            tags: widget.tags,
                          ))),
                );
              },
              trailing: DeletePost(
                  postUserRef: widget.userRef,
                  postRef: widget.postRef,
                  groupRef: widget.groupRef,
                  currUserRef: widget.currUserRef,
                  media: widget.media),
            ),
            // CAN DELETE POST EITHER VIA DELETE POST BUTTON OR DISMISSAL, PROBABLY CHOOSE ONE OR THE OTHER EVENTUALLY
            onDismissed: (DismissDirection direction) async {
              await _posts.deletePost(
                  postRef: widget.postRef,
                  userRef: widget.currUserRef,
                  groupRef: widget.groupRef,
                  media: widget.media);
            },
          )
        ]));
  }
}
