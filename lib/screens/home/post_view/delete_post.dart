import 'package:flutter/material.dart';
import 'package:hs_connect/services/posts_database.dart';

class DeletePost extends StatefulWidget {
  final String currUserId;
  final String postUserId;
  final String postId;
  const DeletePost({Key? key, required String this.currUserId, required String this.postUserId, required String this.postId}) : super(key: key);

  @override
  _DeletePostState createState() => _DeletePostState();
}

class _DeletePostState extends State<DeletePost> {

  PostsDatabaseService _posts = PostsDatabaseService();


  @override
  Widget build(BuildContext context) {

  if(widget.currUserId!=widget.postUserId) {
    return Container();
  } else {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {_posts.deletePost(postId: widget.postId, userId: widget.currUserId);},
    );
  }
  }
}
