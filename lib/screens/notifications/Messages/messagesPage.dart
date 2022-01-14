import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/notifications/Messages/messagesForm.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';

import 'messagesFeed.dart';

class MessagesPage extends StatelessWidget {
  final DocumentReference otherUserRef;
  final DocumentReference currUserRef;

  const MessagesPage({Key? key, required this.otherUserRef, required this.currUserRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeColor.white,
        appBar: AppBar(
          backgroundColor: ThemeColor.white,
          title: Text('HII', style: ThemeText.titleRegular()),
          leading: myBackButtonIcon(context),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.max, children: <Widget>[
          MessagesFeed(currUserRef: currUserRef, otherUserRef: otherUserRef,),
          Spacer(),
          MessagesForm(currUserRef: currUserRef, otherUserRef: otherUserRef)
        ]));
  }
}
