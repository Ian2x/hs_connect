import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/replyView/replyCard.dart';
import 'package:hs_connect/screens/home/replyView/replyForm.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class RepliesFeed extends StatefulWidget {
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference groupRef;

  const RepliesFeed({Key? key, required this.commentRef, required this.postRef, required this.groupRef})
      : super(key: key);

  @override
  _RepliesFeedState createState() => _RepliesFeedState();
}

class _RepliesFeedState extends State<RepliesFeed> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    RepliesDatabaseService _replies = RepliesDatabaseService(commentRef: widget.commentRef, currUserRef: userData.userRef);

    return StreamBuilder(
      stream: _replies.commentReplies,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        } else {
          final replies = (snapshot.data as List<Reply?>).map((reply) => reply!).toList();

          return Flexible(
            //height: 200.0,
            child: ListView.builder(
              itemCount: replies.length + 1,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                // when scroll up/down, fires once
                if (index == replies.length) {
                  return ReplyForm(commentRef: widget.commentRef, postRef: widget.postRef, groupRef: widget.groupRef);
                } else {
                  return Center(
                      child: ReplyCard(
                    reply: replies[index],
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
