import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/Messages/messagesPage.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class DMButton extends StatelessWidget {
  final DocumentReference? otherUserRef;
  final DocumentReference currUserRef;
  final String otherUserFundName;

  const DMButton({Key? key, required this.otherUserRef,
    required this.currUserRef,
    required this.otherUserFundName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    return IconButton(
      constraints: BoxConstraints(),
      padding: EdgeInsets.only(top: 3*hp, right: 10*wp),
      onPressed: () {
        if (otherUserRef != null && otherUserRef != currUserRef) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => pixelProvider(context,
                      child: MessagesPage(
                        currUserRef: currUserRef,
                        otherUserRef: otherUserRef!,
                        otherUserFundName: otherUserFundName,
                        onUpdateLastMessage: () {},
                        onUpdateLastViewed: () {},
                      ))));
        }
      },
      icon: Icon(Icons.chat_bubble_outline_rounded, size: 18 * hp, color: Theme.of(context).colorScheme.primary),
    );
  }
}
