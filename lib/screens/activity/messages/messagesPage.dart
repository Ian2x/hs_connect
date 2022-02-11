import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/Messages/messagesForm.dart';
import 'package:hs_connect/shared/constants.dart';
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
  final UserData otherUserData;
  final UserData currUserData;
  final VoidFunction onUpdateLastMessage;
  final VoidFunction onUpdateLastViewed;

  const MessagesPage(
      {Key? key,
      required this.otherUserData,
      required this.currUserData,
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
      onVerticalDragDown: (DragDownDetails ddd) {
        dismissKeyboard(context);
      },
      onPanUpdate: (details) {
        if (details.delta.dx > 15) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          title: Text(otherUserData.fundamentalName),
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
                          entityRef: otherUserData.userRef,
                          entityCreatorRef: otherUserData.userRef,
                        )));
              },
            ),
          ]
        ),
        body: Column(children: <Widget>[
          Expanded(
              child: Container(
            padding: EdgeInsets.only(left: 10 * wp, right: 10 * wp),
            child: MessagesFeed(
              currUserRef: currUserData.userRef,
              otherUserRef: otherUserData.userRef,
              onUpdateLastViewed: onUpdateLastViewed,
            ),
          )),
          Container(
              height: bottomGradientThickness * hp,
              color: currUserData.domainColor!=null ? currUserData.domainColor! : colorScheme.onSurface),
          MessagesForm(
              currUserRef: currUserData.userRef,
              otherUserRef: otherUserData.userRef,
              onUpdateLastMessage: onUpdateLastMessage,
              onUpdateLastViewed: onUpdateLastViewed)
        ]),
      ),
    );
  }
}