import 'package:flutter/material.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:bubble/bubble.dart';

class MessagesBubble extends StatelessWidget {
  final Message message;
  final bool isSentMessage;
  final double wp;
  final double hp;

  const MessagesBubble({Key? key, required this.message, required this.isSentMessage, required this.wp, required this.hp}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (message.timeMessage) {
      return Container(
          margin: EdgeInsets.only(top: 5*hp, bottom: 5*hp),
          child: Center(
              child: Text(
                  message.text,
                  style: ThemeText.inter(fontSize: 13*hp)
              )
          )
      );
    }
    if (message.isMedia!) {
      return Container(
          height: 300*hp,
          width: 300*wp,
          margin: EdgeInsets.only(top: 5*hp, bottom: 5*hp),
          child: Align(
              alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
              child: Image.network(message.text, fit: BoxFit.scaleDown)));
    }
    return Container(
      child: Bubble(
          color: isSentMessage ? ThemeColor.secondaryBlue.withOpacity(0.75) : ThemeColor.mediumGrey.withOpacity(0.7),
          margin: BubbleEdges.fromLTRB(isSentMessage ? 50*wp : 0*wp, 5*wp, isSentMessage ? 0 : 50*hp, 5*hp),
          alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
          // nip: isSentMessage ? BubbleNip.rightTop : BubbleNip.leftTop,
          radius: Radius.circular(13*hp),
          child: Container(
            padding: EdgeInsets.only(left:1*wp,right:1*wp,bottom: 1*hp),
            child: Text(message.text, style: ThemeText.roboto(fontSize: 16*hp))
          ),
          elevation: 0,
      ),
    );

  }
}
