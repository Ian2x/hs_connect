import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/services/messages_database.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:intl/intl.dart';

import 'messagesBubble.dart';

class MessagesFeed extends StatefulWidget {
  final DocumentReference otherUserRef;
  final DocumentReference currUserRef;
  final VoidFunction onUpdateLastViewed;
  final double wp;
  final double hp;

  const MessagesFeed(
      {Key? key, required this.otherUserRef, required this.currUserRef, required this.onUpdateLastViewed, required this.wp, required this.hp})
      : super(key: key);

  @override
  _MessagesFeedState createState() => _MessagesFeedState();
}

class _MessagesFeedState extends State<MessagesFeed> {

  double? wp;
  double? hp;
  @override
  void initState() {
    if (mounted) {
      setState(() {
        wp = widget.wp;
        hp = widget.hp;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.onUpdateLastViewed();
    MessagesDatabaseService _messages =
        new MessagesDatabaseService(currUserRef: widget.currUserRef, otherUserRef: widget.otherUserRef);
    _messages.updateLastViewed(widget.currUserRef, widget.otherUserRef);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (wp==null || hp == null) return Loading();

    MessagesDatabaseService _messages =
        new MessagesDatabaseService(currUserRef: widget.currUserRef, otherUserRef: widget.otherUserRef);
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
            messages.sort((a, b) {
              return b.createdAt!.compareTo(a.createdAt!);
            });
            int initialMessagesLength = messages.length;
            String? lastDate;
            for (int i = initialMessagesLength - 1; i >= 0; i--) {
              final tempDate = DateFormat.yMMMMd('en_US').format(messages[i].createdAt!.toDate());
              if (lastDate == null || lastDate.compareTo(tempDate) != 0) {
                messages.insert(
                    i + 1,
                    Message(
                        text: tempDate,
                        timeMessage: true,
                        createdAt: null,
                        isMedia: null,
                        numReports: 0,
                        senderRef: null,
                        messageRef: null,
                        receiverRef: null));
                lastDate = tempDate;
              }
            }
            return ListView.builder(
              itemCount: messages.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Container(
                      padding: EdgeInsets.only(bottom: 5*hp!),
                      child: MessagesBubble(
                        message: messages[index],
                        isSentMessage: messages[index].senderRef == widget.currUserRef, wp: wp!, hp: hp!,
                      ));
                }
                if (index == messages.length - 1) {
                  return Container(
                      padding: EdgeInsets.only(top: 5*hp!),
                      child: MessagesBubble(
                        message: messages[index],
                        isSentMessage: messages[index].senderRef == widget.currUserRef, wp: wp!, hp: hp!,
                      ));
                }
                return MessagesBubble(
                  message: messages[index],
                  isSentMessage: messages[index].senderRef == widget.currUserRef, wp: wp!, hp: hp!,
                );
              },
            );
          }
        });
  }
}
