import 'package:flutter/material.dart';
import 'package:hs_connect/models/message.dart';
import 'package:bubble/bubble.dart';

import 'package:hs_connect/shared/widgets/expandableImage.dart';

class MessagesBubble extends StatelessWidget {
  final Message message;
  final bool isSentMessage;

  MessagesBubble({Key? key, required this.message, required this.isSentMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (message.timeMessage) {
      return Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Center(child: Text(message.text, style: textTheme.bodyText2)));
    }
    if (message.isMedia!) {
      return Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Align(
              alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
              child: ExpandableImage(imageURL: message.text, maxHeight: 900, containerWidth: 300)));
    }
    return Bubble(
      color: isSentMessage ? colorScheme.secondary : colorScheme.primary.withOpacity(0.3),
      margin: BubbleEdges.fromLTRB(isSentMessage ? 50 : 10, 3, isSentMessage ? 10 : 50, 3),
      alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
      radius: Radius.circular(16),
      child: Container(
          padding: EdgeInsets.fromLTRB(4.5, 0, 4, 1.5),
          child: Text(
            message.text,
            style: textTheme.bodyText1
                ?.copyWith(color: isSentMessage ? Colors.white : colorScheme.onSurface),
            textWidthBasis: TextWidthBasis.longestLine,
          )),
      elevation: 0,
    );
  }
}
