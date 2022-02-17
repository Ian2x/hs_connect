import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/activity/Messages/messagesPage.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class NewMessageButton extends StatefulWidget {
  final DocumentReference otherUserRef;
  final DocumentReference currUserRef;
  final String otherUserFundName;

  const NewMessageButton({Key? key,
    required this.otherUserRef,
    required this.currUserRef,
    required this.otherUserFundName,
  }) : super(key: key);

  @override
  _NewMessageButtonState createState() => _NewMessageButtonState();
}

class _NewMessageButtonState extends State<NewMessageButton> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    return GestureDetector(
      onTap: ()
      {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => pixelProvider(context,
                      child: MessagesPage(
                        currUserRef: widget.currUserRef,
                        otherUserRef: widget.otherUserRef,
                        otherUserFundName:widget.otherUserFundName,
                        onUpdateLastMessage: () {},
                        onUpdateLastViewed: () {},
                      ))));
      },
      child: Container(
        margin:EdgeInsets.fromLTRB(13*wp,20*hp,18*wp,0),
        padding: EdgeInsets.all(15*hp),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(60)),
            color: Theme.of(context).colorScheme.onError,
        ),
        child: Row(
          children: [
            SizedBox(width:15*hp),
            Text("Message...",
              style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize:14),
            ),
          ],
        ),
      ),
    );
  }
}
