import 'package:flutter/material.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/shared/constants.dart';

class MessagesCard extends StatelessWidget {
  final Message message;
  final bool isSentMessage;

  const MessagesCard({Key? key, required this.message, required this.isSentMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
            child: message.isMedia
                ? Container(height: 300, width: 300, child: Image.network(message.text, fit: BoxFit.scaleDown))
                : Container(padding: EdgeInsets.all(10), child: Text(message.text))));
  }
}
