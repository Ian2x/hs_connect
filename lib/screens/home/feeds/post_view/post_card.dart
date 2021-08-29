import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String userId;
  final String groupId;
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

  bool liked = false;
  bool disliked = false;

  @override
  void initState() {
    if(widget.likes.contains(widget.currUserId)) {
      setState(() {liked = true;});
    } else if (widget.likes.contains(widget.currUserId)) {
      setState(() {disliked = true;});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ListTile(
            title: Text(widget.text),
            subtitle: Text(widget.userId),

          ),
        ]));
  }
}
