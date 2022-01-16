import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/notifications/Messages/messagesForm.dart';
import 'package:hs_connect/services/user_data_database.dart';
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
      resizeToAvoidBottomInset: true,
      backgroundColor: ThemeColor.white,
      appBar: PreferredSize(preferredSize: Size.fromHeight(100),
      child: MessagesPageAppBar(currUserRef: currUserRef, otherUserRef: otherUserRef)),
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(children: <Widget>[
          Expanded(
              child: MessagesFeed(
                currUserRef: currUserRef,
                otherUserRef: otherUserRef,
              )),
          Container(
            color: Colors.transparent,
            child: SizedBox(height: 10),
          ),
          MessagesForm(currUserRef: currUserRef, otherUserRef: otherUserRef)
        ]),
      ),
    );
  }
}

class MessagesPageAppBar extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference otherUserRef;
  const MessagesPageAppBar({Key? key, required this.currUserRef, required this.otherUserRef}) : super(key: key);

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
    
    return AppBar(
      backgroundColor: ThemeColor.white,
      title: Text(otherUserUsername, style: ThemeText.titleRegular()),
      leading: myBackButtonIcon(context),
    );
  }
}
