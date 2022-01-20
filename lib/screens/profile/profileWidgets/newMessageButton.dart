import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/activity/Messages/messagesPage.dart';
import 'package:hs_connect/shared/constants.dart';

class NewMessageButton extends StatefulWidget {
  final DocumentReference otherUserRef;
  final DocumentReference currUserRef;

  const NewMessageButton({Key? key, required this.otherUserRef, required this.currUserRef}) : super(key: key);

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
    return SizedBox(
        height: 150,
        width: 300,
        child: Column(children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Message", style: ThemeText.groupBold(fontSize: 24), textAlign: TextAlign.left),
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 100,
                width: 300,
                child: Overlay(initialEntries: <OverlayEntry>[
                  OverlayEntry(builder: (BuildContext context) {
                    return TextField(
                      decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Start a Chat"),
                      focusNode: myFocusNode,
                    );
                  }),
                  OverlayEntry(builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        myFocusNode.requestFocus();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MessagesPage(
                                      currUserRef: widget.currUserRef,
                                      otherUserRef: widget.otherUserRef,
                                    )));
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
