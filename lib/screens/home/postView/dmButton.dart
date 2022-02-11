import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/Messages/messagesPage.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class dmButton extends StatelessWidget {
  final UserData? otherUserData;
  final UserData currUserData;

  const dmButton({Key? key, required this.otherUserData, required this.currUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;

    return IconButton(
      constraints: BoxConstraints(),
      onPressed: () {
        if (otherUserData != null && otherUserData!.userRef != currUserData.userRef) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => pixelProvider(context,
                      child: MessagesPage(
                        currUserData: currUserData,
                        otherUserData: otherUserData!,
                        onUpdateLastMessage: () {},
                        onUpdateLastViewed: () {},
                      ))));
        }
      },
      icon: Icon(Icons.chat_bubble_outline_rounded, size: 18 * hp, color: Theme.of(context).colorScheme.primary),
    );
  }
}
