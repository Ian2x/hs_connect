import 'package:flutter/material.dart';
import 'package:hs_connect/services/posts_database.dart';

class DeletePost extends StatefulWidget {
  final String currUserId;
  final String postUserId;
  final String postId;
  final String? image;
  const DeletePost({Key? key, required this.currUserId, required this.postUserId, required this.postId, this.image}) : super(key: key);

  @override
  _DeletePostState createState() => _DeletePostState();
}

class _DeletePostState extends State<DeletePost> {

  PostsDatabaseService _posts = PostsDatabaseService();


  @override
  Widget build(BuildContext context) {

  if(widget.currUserId!=widget.postUserId) {
    return Container(
      height: 0.0,
      width: 0.0,
    );
  } else {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {_posts.deletePost(postId: widget.postId, userId: widget.currUserId, image: widget.image);},
    );
  }
  }
}
