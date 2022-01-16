import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/services/messages_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/loading.dart';

import 'messagesBubble.dart';


class MessagesFeed extends StatefulWidget {
  final DocumentReference otherUserRef;
  final DocumentReference currUserRef;
  const MessagesFeed({Key? key, required this.otherUserRef, required this.currUserRef}) : super(key: key);

  @override
  _MessagesFeedState createState() => _MessagesFeedState();
}

class _MessagesFeedState extends State<MessagesFeed> {

  @override
  void dispose() {
    MessagesDatabaseService _messages = new MessagesDatabaseService(currUserRef: widget.currUserRef, otherUserRef: widget.otherUserRef);
    _messages.updateLastViewed(widget.currUserRef, widget.otherUserRef);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    MessagesDatabaseService _messages = new MessagesDatabaseService(currUserRef: widget.currUserRef, otherUserRef: widget.otherUserRef);
    return StreamBuilder(
      stream: _messages.messagesWithOtherPerson,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        } else {
          List<Message?> messagess = (snapshot.data as List<Message?>);
          messagess.removeWhere((value) => value == null);
          List<Message> messages = messagess.map((item) => item!).toList();
          // sort by most recent
          messages.sort((a,b) {
            return b.createdAt.compareTo(a.createdAt);
          });
          return ListView.builder(
            itemCount: messages.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            reverse: true,
            itemBuilder: (BuildContext context, int index) {
              return MessagesBubble(message: messages[index], isSentMessage: messages[index].senderRef==widget.currUserRef,);
            },
          );
        }
    });
  }
}

