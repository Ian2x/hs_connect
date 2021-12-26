import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/comment_view/comment_card.dart';
import 'package:hs_connect/screens/home/comment_view/comment_form.dart';
import 'package:hs_connect/screens/home/post_view/post_card.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:provider/provider.dart';

class CommentsFeed extends StatefulWidget {
  final DocumentReference postRef;
  const CommentsFeed({Key? key, required this.postRef}) : super(key: key);

  @override
  _CommentsFeedState createState() => _CommentsFeedState();
}

class _CommentsFeedState extends State<CommentsFeed> {
  //String groupId = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    CommentsDatabaseService _comments = CommentsDatabaseService(postRef: widget.postRef);

    return StreamBuilder(
      stream: _comments.postComments,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (!snapshot.hasData) {
          print('no data :/');
          return Loading();
        } else {
          final comments = (snapshot.data as List<Comment?>).map((comment) => comment!).toList();

          return Flexible(
            //height: 200.0,
            child: ListView.builder(
              itemCount: comments.length+1,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                // when scroll up/down, fires once
                if(index==comments.length) {
                  return CommentForm(postRef: widget.postRef);
                } else {
                  return Center(
                      child: CommentCard(
                        commentRef: comments[index].commentRef,
                        postRef: comments[index].postRef,
                        userRef: comments[index].userRef,
                        text: comments[index].text,
                        media: comments[index].media,
                        createdAt: comments[index].createdAt,
                        likes: comments[index].likes,
                        dislikes: comments[index].dislikes,
                        currUserRef: userData.userRef,
                      ));
                }
              },
            ),
          );
        }
      },
    );
  }
}
