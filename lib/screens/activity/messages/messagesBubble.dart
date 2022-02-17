import 'package:flutter/material.dart';
import 'package:hs_connect/models/message.dart';
import 'package:bubble/bubble.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/expandableImage.dart';
import 'package:provider/provider.dart';

class MessagesBubble extends StatelessWidget {
  final Message message;
  final bool isSentMessage;

  MessagesBubble({Key? key, required this.message, required this.isSentMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (message.timeMessage) {
      return Container(
          margin: EdgeInsets.only(top: 5 * hp, bottom: 5 * hp),
          child: Center(child: Text(message.text, style: textTheme.bodyText2)));
    }
    if (message.isMedia!) {
      return Container(
          margin: EdgeInsets.only(top: 5 * hp, bottom: 5 * hp),
          child: Align(
              alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
              child: ExpandableImage(imageURL: message.text, maxHeight: 900 * hp, containerWidth: 300 * wp)));
    }
    return Bubble(
      color: isSentMessage ? Colors.blue : colorScheme.primary.withOpacity(0.3),
      margin: BubbleEdges.fromLTRB(isSentMessage ? 50 * wp : 0 * wp, 5 * wp, isSentMessage ? 0 : 50 * hp, 5 * hp),
      alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
      radius: Radius.circular(11 * hp),
      child: Container(
          padding: EdgeInsets.fromLTRB(4 * wp, 0, 4 * wp, 1 * hp),
          child: Text(
            message.text,
            style: textTheme.bodyText2?.copyWith
              (fontSize: 15.5 * hp,
                color: isSentMessage?  Colors.white : colorScheme.onSurface),
            textWidthBasis: TextWidthBasis.longestLine,
          )),
      elevation: 0,
    );
  }
}
