import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/activity/Messages/messagesPage.dart';
import 'package:hs_connect/shared/widgets/chatIcons.dart';

class DMButton extends StatelessWidget {
  final DocumentReference? otherUserRef;
  final DocumentReference currUserRef;
  final String otherUserFundName;

  const DMButton({
    Key? key,
    required this.otherUserRef,
    required this.currUserRef,
    required this.otherUserFundName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: BoxConstraints(),
      padding: EdgeInsets.only(top: 5, right: 10, bottom: 5),
      onPressed: () {
        if (otherUserRef != null && otherUserRef != currUserRef) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MessagesPage(
                        currUserRef: currUserRef,
                        otherUserRef: otherUserRef!,
                        otherUserFundName: otherUserFundName,
                        onUpdateLastMessage: () {},
                        onUpdateLastViewed: () {},
                      )));
        }
      },
      icon: Icon(Chat.chat_bubble, size: 18, color: Theme.of(context).colorScheme.primary),
    );
  }
}
