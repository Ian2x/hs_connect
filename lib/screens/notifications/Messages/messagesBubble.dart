import 'package:flutter/material.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:bubble/bubble.dart';

class MessagesBubble extends StatelessWidget {
  final Message message;
  final bool isSentMessage;

  const MessagesBubble({Key? key, required this.message, required this.isSentMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.isMedia) {
      return Container(
          height: 300,
          width: 300,
          child: Align(
              alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
              child: Image.network(message.text, fit: BoxFit.scaleDown)));
    }
    return Container(
      child: Bubble(
          margin: BubbleEdges.fromLTRB(isSentMessage ? 50 : 0, 5, isSentMessage ? 0 : 50, 5),
          alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
          nip: isSentMessage ? BubbleNip.rightTop : BubbleNip.leftTop,
          child: Text(message.text)),
    );

  }
}
