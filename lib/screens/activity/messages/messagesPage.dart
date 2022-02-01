import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/Messages/messagesForm.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:provider/provider.dart';

import 'messagesFeed.dart';

class MessagesPage extends StatelessWidget {
  final UserData otherUserData;
  final DocumentReference currUserRef;
  final VoidFunction onUpdateLastMessage;
  final VoidFunction onUpdateLastViewed;

  const MessagesPage(
      {Key? key,
      required this.otherUserData,
      required this.currUserRef,
      required this.onUpdateLastMessage,
      required this.onUpdateLastViewed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: colorScheme.background,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50*hp),
            child: MessagesPageAppBar(otherUserData: otherUserData,)),
        body: Container(
          padding: EdgeInsets.only(bottom: 10*hp),
          child: Column(children: <Widget>[
            Expanded(
                child: Container(
              padding: EdgeInsets.only(left: 10*wp, right: 10*wp),
              child: MessagesFeed(
                currUserRef: currUserRef,
                otherUserRef: otherUserData.userRef,
                onUpdateLastViewed: onUpdateLastViewed,
              ),
            )),
            Container(
              height: bottomGradientThickness*hp,
              decoration: BoxDecoration(
                gradient: Gradients.blueRed(),
              )
            ),
            Container(
              child: SizedBox(height: 10*hp),
            ),
            Container(
                padding: EdgeInsets.only(left: 10*wp, right: 10*wp),
                child: MessagesForm(
                    currUserRef: currUserRef,
                    otherUserRef: otherUserData.userRef,
                    onUpdateLastMessage: onUpdateLastMessage,
                    onUpdateLastViewed: onUpdateLastViewed))
          ]),
        ),
      ),
    );
  }
}

class MessagesPageAppBar extends StatelessWidget {
  final UserData otherUserData;

  const MessagesPageAppBar({Key? key, required this.otherUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      title: Text(otherUserData.fundamentalName, style: Theme.of(context).textTheme.headline6),
      leading: myBackButtonIcon(context),
      elevation: 0,
      bottom: PreferredSize(
          child: Container(
            decoration: BoxDecoration(
              gradient: Gradients.blueRed()
            ),
            //color: colorScheme.primary,
            height: topGradientThickness*hp,
          ),
          preferredSize: Size.fromHeight(topGradientThickness*hp)),
    );
  }
}
