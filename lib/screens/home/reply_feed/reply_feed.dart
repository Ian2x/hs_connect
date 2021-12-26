import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/comment_view/comment_card.dart';
import 'package:hs_connect/screens/home/comment_view/comment_form.dart';
import 'package:hs_connect/screens/home/post_view/post_card.dart';
import 'package:hs_connect/screens/home/reply_view/reply_card.dart';
import 'package:hs_connect/screens/home/reply_view/reply_form.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class RepliesFeed extends StatefulWidget {
  final DocumentReference commentRef;
  final DocumentReference postRef;
  const RepliesFeed({Key? key, required this.commentRef, required this.postRef}) : super(key: key);

  @override
  _RepliesFeedState createState() => _RepliesFeedState();
}

class _RepliesFeedState extends State<RepliesFeed> {
  // String groupId = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    RepliesDatabaseService _replies = RepliesDatabaseService(commentRef: widget.commentRef);

    return StreamBuilder(
      stream: _replies.commentReplies,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (!snapshot.hasData) {
          return Loading();
        } else {
          final replies = (snapshot.data as List<Reply?>).map((reply) => reply!).toList();
          // print(posts.map((post) => post!.image));

          return Flexible(
            //height: 200.0,
            child: ListView.builder(
              itemCount: replies.length+1,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                // when scroll up/down, fires once
                if(index==replies.length) {
                  return ReplyForm(commentRef: widget.commentRef, postRef: widget.postRef,);
                } else {
                  return Center(
                      child: ReplyCard(
                        replyRef: replies[index].replyRef,
                        commentRef: replies[index].commentRef,
                        postRef: replies[index].postRef,
                        userRef: replies[index].userRef,
                        text: replies[index].text,
                        media: replies[index].media,
                        createdAt: replies[index].createdAt,
                        likes: replies[index].likes,
                        dislikes: replies[index].dislikes,
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
