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
    if (message.timeMessage) {
      return Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Center(
              child: Text(
                  message.text,
                  style: ThemeText.inter(fontSize: 13)
              )
          )
      );
    }
    if (message.isMedia!) {
      return Container(
          height: 300,
          width: 300,
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Align(
              alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
              child: Image.network(message.text, fit: BoxFit.scaleDown)));
    }
    return Container(
      child: Bubble(
          color: isSentMessage ? ThemeColor.secondaryBlue.withOpacity(0.75) : ThemeColor.mediumGrey.withOpacity(0.7),
          margin: BubbleEdges.fromLTRB(isSentMessage ? 50 : 0, 5, isSentMessage ? 0 : 50, 5),
          alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
          // nip: isSentMessage ? BubbleNip.rightTop : BubbleNip.leftTop,
          radius: Radius.circular(13),
          child: Container(
            padding: EdgeInsets.only(left:1,right:1,bottom: 1),
            child: Text(message.text, style: ThemeText.roboto(fontSize: 16))
          ),
          elevation: 0,
      ),
    );

  }
}
