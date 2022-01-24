import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/Messages/messagesForm.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';

import 'messagesFeed.dart';

class MessagesPage extends StatelessWidget {
  final DocumentReference otherUserRef;
  final DocumentReference currUserRef;
  final VoidFunction onUpdateLastMessage;
  final VoidFunction onUpdateLastViewed;

  const MessagesPage(
      {Key? key,
      required this.otherUserRef,
      required this.currUserRef,
      required this.onUpdateLastMessage,
      required this.onUpdateLastViewed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double wp = getWp(context);
    double hp = getHp(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: ThemeColor.white,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50*hp),
            child: MessagesPageAppBar(currUserRef: currUserRef, otherUserRef: otherUserRef, hp: hp)),
        body: Container(
          padding: EdgeInsets.only(bottom: 10*hp),
          child: Column(children: <Widget>[
            Expanded(
                child: Container(
              padding: EdgeInsets.only(left: 10*wp, right: 10*wp),
              child: MessagesFeed(
                currUserRef: currUserRef,
                otherUserRef: otherUserRef,
                onUpdateLastViewed: onUpdateLastViewed,
                wp: wp, hp: hp
              ),
            )),
            Divider(height: 0.5*hp, color: ThemeColor.mediumGrey),
            Container(
              child: SizedBox(height: 10*hp),
            ),
            Container(
                padding: EdgeInsets.only(left: 10*wp, right: 10*wp),
                child: MessagesForm(
                    currUserRef: currUserRef,
                    otherUserRef: otherUserRef,
                    onUpdateLastMessage: onUpdateLastMessage,
                    onUpdateLastViewed: onUpdateLastViewed,
                    wp: wp, hp: hp))
          ]),
        ),
      ),
    );
  }
}

class MessagesPageAppBar extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference otherUserRef;
  final double hp;

  const MessagesPageAppBar({Key? key, required this.currUserRef, required this.otherUserRef, required this.hp}) : super(key: key);

  @override
  _MessagesPageAppBarState createState() => _MessagesPageAppBarState();
}

class _MessagesPageAppBarState extends State<MessagesPageAppBar> {
  String otherUserUsername = '';

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  void getUserData() async {
    UserDataDatabaseService _userDataDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    final UserData? fetchUserData = await _userDataDatabaseService.getUserData(userRef: widget.otherUserRef);
    if (mounted) {
      setState(() {
        otherUserUsername = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double hp = getHp(context);
    return AppBar(
      backgroundColor: ThemeColor.white,
      title: Text(otherUserUsername, style: ThemeText.titleRegular()),
      leading: myBackButtonIcon(context),
      elevation: 0,
      bottom: PreferredSize(
          child: Container(
            color: ThemeColor.mediumGrey,
            height: 0.5*hp,
          ),
          preferredSize: Size.fromHeight(0.5*hp)),
    );
  }
}
