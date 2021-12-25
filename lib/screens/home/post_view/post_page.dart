import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/screens/home/comment_feed/comments_feed.dart';
import 'package:hs_connect/screens/home/comment_view/comment_form.dart';

class PostPage extends StatelessWidget {
  final Post postInfo;

  const PostPage({Key? key, required this.postInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text(postInfo.title),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
      ),
      body: Container(
          child: Column(
              children: <Widget>[
                Text(postInfo.text),
                SizedBox(height: 10.0),
                CommentsFeed(postRef: postInfo.postRef),
                // SizedBox(height: 20.0),
                // CommentForm(postId: postInfo.postId),
              ]
          )
      ),
    );
  }
}
