import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/post_view/post_page.dart';
import 'package:hs_connect/services/userInfo_database.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String userId;
  final String groupId;
  final String title;
  final String text;
  final String? image;
  final String createdAt;
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

  bool liked = false;
  bool disliked = false;
  String username = '<Loading user name...>';

  @override
  void initState() {
    // initialize liked/disliked
    if (widget.likes.contains(widget.currUserId)) {
      setState(() {
        liked = true;
      });
    } else if (widget.likes.contains(widget.currUserId)) {
      setState(() {
        disliked = true;
      });
    }
    // find username for userId
    // _userInfoDatabaseService.userId = widget.userId;
    getUsername();
    super.initState();
  }

  void getUsername() async {
    final UserData? fetchUsername = await _userInfoDatabaseService.getUserData(userId: widget.userId);
    setState(() {
      username = fetchUsername != null ? fetchUsername.displayedName : '<Failed to retrieve user name>';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      ListTile(
        title: Text(widget.title),
        subtitle: Text(username),
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
      ),
    ]));
  }
}
