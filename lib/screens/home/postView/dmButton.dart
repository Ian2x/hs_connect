import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/Messages/messagesPage.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class dmButton extends StatefulWidget {
  final UserData? otherUserData;
  final UserData currUserData;

  const dmButton({Key? key, required this.otherUserData, required this.currUserData}) : super(key: key);

  @override
  _dmButtonState createState() => _dmButtonState();
}

class _dmButtonState extends State<dmButton> {
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    return
          Container(
            margin:EdgeInsets.symmetric(vertical: 0,horizontal:30.0),
            height: 15*hp,
            width: 15*wp,
            child: Overlay(initialEntries: <OverlayEntry>[
              OverlayEntry(builder: (BuildContext context) {
                return Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary);
              }),
              OverlayEntry(builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    myFocusNode.requestFocus();
                    if (widget.otherUserData != null && widget.otherUserData!.userRef != widget.currUserData.userRef){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => pixelProvider(context, child: MessagesPage(
                                currUserData: widget.currUserData,
                                otherUserData: widget.otherUserData!,
                                onUpdateLastMessage: () {},
                                onUpdateLastViewed: () {},
                              ))));
                      }
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(),
                );
              }),
            ]),
          );
  }
}
