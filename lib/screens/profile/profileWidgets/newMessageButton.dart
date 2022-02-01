import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/Messages/messagesPage.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class NewMessageButton extends StatefulWidget {
  final UserData otherUserData;
  final DocumentReference currUserRef;

  const NewMessageButton({Key? key, required this.otherUserData, required this.currUserRef}) : super(key: key);

  @override
  _NewMessageButtonState createState() => _NewMessageButtonState();
}

class _NewMessageButtonState extends State<NewMessageButton> {
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

    return Container(
        margin: EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width*.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Message", style: Theme.of(context).textTheme.headline5, textAlign: TextAlign.left),
          ),
          SizedBox(height: 20*hp),
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 52*hp,
                width: 300*wp,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16*hp),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onError,
                        width: 3*hp,
                      )),
                ),
                child: Overlay(initialEntries: <OverlayEntry>[
                  OverlayEntry(builder: (BuildContext context) {
                    return TextField(
                      decoration: InputDecoration(hintStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).hintColor), border: InputBorder.none, hintText: "   Send a chat"),
                    );
                  }),
                  OverlayEntry(builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        myFocusNode.requestFocus();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => pixelProvider(context, child: MessagesPage(
                                  currUserRef: widget.currUserRef,
                                  otherUserData: widget.otherUserData,
                                  onUpdateLastMessage: () {},
                                  onUpdateLastViewed: () {},
                                ))));
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(),
                    );
                  }),
                ]),
              ))
        ]));
  }
}
