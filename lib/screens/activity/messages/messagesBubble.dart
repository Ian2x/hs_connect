import 'package:flutter/material.dart';
import 'package:hs_connect/models/message.dart';
import 'package:bubble/bubble.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
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

    if (message.timeMessage) {
      return Container(
          margin: EdgeInsets.only(top: 5*hp, bottom: 5*hp),
          child: Center(
              child: Text(
                  message.text,
                  style: Theme.of(context).textTheme.bodyText2
              )
          )
      );
    }
    if (message.isMedia!) {
      return Container(
          //height: 300*hp,
          //width: 300*wp,
          margin: EdgeInsets.only(top: 5*hp, bottom: 5*hp),
          child: Align(
              alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
              child: ExpandableImage(imageURL: message.text, maxHeight: 900*hp, containerWidth: 300*wp)));
    }
    return Bubble(
        color: isSentMessage ? colorScheme.secondary.withOpacity(0.6) : colorScheme.primary.withOpacity(0.4),
        margin: BubbleEdges.fromLTRB(isSentMessage ? 50*wp : 0*wp, 5*wp, isSentMessage ? 0 : 50*hp, 5*hp),
        alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
        radius: Radius.circular(11*hp),
        child: Container(
          padding: EdgeInsets.only(left:4*wp,right:4*wp,bottom: 1*hp),
          child: Text(
            message.text,
            style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 15.5 * hp),
            textWidthBasis: TextWidthBasis.longestLine,
          )),
        elevation: 0,
    );

  }
}
