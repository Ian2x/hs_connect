import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/activity/Messages/messagesPage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

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
    return Container(
        margin: EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width*.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Message", style: ThemeText.groupBold(fontSize: 24), textAlign: TextAlign.left),
          ),
          SizedBox(height: 20),
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: MediaQuery.of(context).size.height/15,
                width: 300,
                decoration: ShapeDecoration(
                  color: HexColor('FFFFFF'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: BorderSide(
                        color: ThemeColor.backgroundGrey,
                        width: 3.0,
                      )),
                ),
                child: Overlay(initialEntries: <OverlayEntry>[
                  OverlayEntry(builder: (BuildContext context) {
                    return TextField(
                      decoration: InputDecoration(hintStyle: ThemeText.roboto(fontSize: 18, color: ThemeColor.lightMediumGrey), border: InputBorder.none, hintText: "   Send a chat"),
                      //focusNode: myFocusNode,
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
                                      onUpdateLastMessage: () {},
                                      onUpdateLastViewed: () {},
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
