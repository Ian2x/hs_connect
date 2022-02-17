import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/screens/activity/Messages/messagesForm.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:hs_connect/shared/widgets/myDivider.dart';
import 'package:provider/provider.dart';

import 'messagesFeed.dart';

class MessagesPage extends StatelessWidget {
  final DocumentReference otherUserRef;
  final String otherUserFundName;
  final DocumentReference currUserRef;
  final VoidFunction onUpdateLastMessage;
  final VoidFunction onUpdateLastViewed;

  const MessagesPage(
      {Key? key,
      required this.otherUserRef,
      required this.currUserRef,
      required this.otherUserFundName,
      required this.onUpdateLastMessage,
      required this.onUpdateLastViewed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(otherUserFundName),
        leading: myBackButtonIcon(context),
        elevation: 0,
        bottom: MyDivider(),
        actions: [
          IconButton(
            constraints: BoxConstraints(),
            splashRadius: .1,
            icon: Icon(Icons.more_horiz, size: 24 * hp, color: colorScheme.primary),
            padding: EdgeInsets.fromLTRB(8*wp, 8*hp, 14*wp, 8*hp),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20 * hp),
                      )),
                  builder: (context) => pixelProvider(context,
                      child: ReportSheet(
                        reportType: ReportType.message,
                        entityRef: otherUserRef,
                        entityCreatorRef: otherUserRef
                      )));
            },
          ),
        ]
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5*hp),
              child: GestureDetector(
                onVerticalDragDown: (DragDownDetails ddd) {
                  dismissKeyboard(context);
                },
                onPanUpdate: (details) {
                  if (details.delta.dx > 15) {
                    Navigator.of(context).pop();
                  }
                },
                child: MessagesFeed(
                  currUserRef: currUserRef,
                  otherUserRef: otherUserRef,
                  onUpdateLastViewed: onUpdateLastViewed,
                ),
              ),
            )),
        Container(
            height: 0,
            color:  colorScheme.onSurface), //can add domain color but...
        MessagesForm(
            currUserRef: currUserRef,
            otherUserRef: otherUserRef,
            onUpdateLastMessage: onUpdateLastMessage,
            onUpdateLastViewed: onUpdateLastViewed)
      ]),
    );
  }
}