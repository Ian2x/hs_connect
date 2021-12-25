import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/posts_database.dart';

class DeletePost extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference postUserRef;
  final DocumentReference postRef;
  final String? image;
  const DeletePost({Key? key, required this.currUserRef, required this.postUserRef, required this.postRef, this.image}) : super(key: key);

  @override
  _DeletePostState createState() => _DeletePostState();
}

class _DeletePostState extends State<DeletePost> {

  PostsDatabaseService _posts = PostsDatabaseService();


  @override
  Widget build(BuildContext context) {

  if(widget.currUserRef!=widget.postUserRef) {
    return Container(
      height: 0.0,
      width: 0.0,
    );
  } else {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {_posts.deletePost(postRef: widget.postRef, userRef: widget.currUserRef, image: widget.image);},
    );
  }
  }
}
