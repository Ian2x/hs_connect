import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class DeletePost extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference postUserRef;
  final DocumentReference groupRef;
  final DocumentReference postRef;
  final String? media;

  const DeletePost(
      {Key? key,
      required this.currUserRef,
      required this.postUserRef,
      required this.groupRef,
      required this.postRef,
      this.media})
      : super(key: key);

  @override
  _DeletePostState createState() => _DeletePostState();
}

class _DeletePostState extends State<DeletePost> {

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.currUserRef);

    if (widget.currUserRef != widget.postUserRef) {
      return Container();
    } else {
      return IconButton(
        icon: Icon(Icons.delete),
        iconSize: 24*hp,
        onPressed: () {
          _posts.deletePost(
              postRef: widget.postRef, userRef: widget.currUserRef, groupRef: widget.groupRef, media: widget.media);
        },
      );
    }
  }
}
