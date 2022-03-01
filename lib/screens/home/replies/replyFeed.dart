import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/replies/replyCard.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class RepliesFeed extends StatelessWidget {
  final DocumentReference commentRef;
  final DocumentReference postCreatorRef;
  final Color? groupColor;

  const RepliesFeed({Key? key, required this.commentRef, required this.postCreatorRef, required this.groupColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    RepliesDatabaseService _replies = RepliesDatabaseService(commentRef: commentRef, currUserRef: userData.userRef);

    return StreamBuilder(
      stream: _replies.commentReplies,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          final replies = (snapshot.data as List<Reply?>).map((reply) => reply!).toList();
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: replies.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              if (userData.blockedUserRefs.contains(replies[index].creatorRef)) {
                return Container();
              }
              return Center(
                  child: ReplyCard(
                reply: replies[index],
                currUserData: userData,
                postCreatorRef: postCreatorRef,
                groupColor: groupColor,
              ));
            },
          );
        }
      },
    );
  }
}
