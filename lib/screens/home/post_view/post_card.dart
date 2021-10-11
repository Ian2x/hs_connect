import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/post_feeds/specific_group_feed.dart';
import 'package:hs_connect/screens/home/post_view/delete_post.dart';
import 'package:hs_connect/screens/home/post_view/like_dislike_post.dart';
import 'package:hs_connect/screens/home/post_view/post_page.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String userId;
  final String groupId;
  final String title;
  final String text;
  final String? image;
  final Timestamp createdAt;
  List<String> likes;
  List<String> dislikes;
  final String currUserId;

  PostCard(
      {Key? key,
      required this.postId,
      required this.userId,
      required this.groupId,
      required this.title,
      required this.text,
      required this.image,
      required this.createdAt,
      required this.likes,
      required this.dislikes,
      required this.currUserId})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  UserInfoDatabaseService _userInfoDatabaseService = UserInfoDatabaseService();

  GroupsDatabaseService _groups = GroupsDatabaseService();

  PostsDatabaseService _posts = PostsDatabaseService();

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';
  String groupName = '<Loading group name...>';
  Image groupImage = Image(image: AssetImage('assets/masonic-G.png'), height: 20, width: 20);

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.likes.contains(widget.currUserId)) {
      setState(() {
        liked = true;
      });
    } else if (widget.dislikes.contains(widget.currUserId)) {
      setState(() {
        disliked = true;
      });
    }
    // find username for userId
    // _userInfoDatabaseService.userId = widget.userId;
    getUsername();
    getGroupName();
    super.initState();
  }

  void getUsername() async {
    final UserData? fetchUsername = await _userInfoDatabaseService.getUserData(userId: widget.userId);
    setState(() {
      username = fetchUsername != null ? fetchUsername.displayedName : '<Failed to retrieve user name>';
    });
  }

  void getGroupName() async {
    final Group? fetchGroupName = await _groups.getGroupData(groupId: widget.groupId);
    setState(() {
      groupName = fetchGroupName != null ? fetchGroupName.name : '<Failed to retrieve group name>';
    });
  }

  void openSpecificGroupFeed() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SpecificGroupFeed(
            groupId: widget.groupId,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Dismissible(
        key: ValueKey(widget.postId),
        child: ListTile(
          title: Row(children: <Widget>[
            IconButton(
              icon: groupImage,
              onPressed: openSpecificGroupFeed,
            ),
            Text(widget.title),
          ]),
          subtitle: Column(children: <Widget>[
            Text(username + ' in ' + groupName),
            widget.image != null ? Image.network(widget.image!) : Container(),
            LikeDislikePost(
                currUserId: widget.currUserId, postId: widget.postId, likes: widget.likes, dislikes: widget.dislikes),
          ]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostPage(
                          postInfo: Post(
                        postId: widget.postId,
                        userId: widget.userId,
                        groupId: widget.groupId,
                        title: widget.title,
                        text: widget.text,
                        image: widget.image,
                        createdAt: widget.createdAt,
                        likes: widget.likes,
                        dislikes: widget.dislikes,
                      ))),
            );
          },
          trailing: DeletePost(
              postUserId: widget.userId, postId: widget.postId, currUserId: widget.currUserId, image: widget.image),
        ),
        // CAN DELETE POST EITHER VIA DELETE POST BUTTON OR DISMISSAL, PROBABLY CHOOSE ONE OR THE OTHER EVENTUALLY
        onDismissed: (DismissDirection direction) async {
          await _posts.deletePost(postId: widget.postId, userId: widget.currUserId, image: widget.image);
        },
      )
    ]));
  }
}
