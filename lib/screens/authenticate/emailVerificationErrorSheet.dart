import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/myOutlinedButton.dart';

import '../wrapper.dart';

class EmailVerificationErrorSheet extends StatefulWidget {
  final VoidFunction cancelTimer;
  final VoidFunction onDeleteEmail;
  final bool emailDeleted;
  final String domainEmail;
  const EmailVerificationErrorSheet({Key? key, required this.cancelTimer, required this.onDeleteEmail, required this.emailDeleted, required this.domainEmail}) : super(key: key);

  @override
  _EmailVerificationErrorSheetState createState() => _EmailVerificationErrorSheetState();
}

class _EmailVerificationErrorSheetState extends State<EmailVerificationErrorSheet> {
  String error = '';
  late String deleteEmail;
  @override
  void initState() {
    if (widget.emailDeleted) {
      deleteEmail = 'Email invalidated';
    } else {
      deleteEmail = 'Invalidate email';
    }
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    final double bottomSpace = max(MediaQuery.of(context).padding.bottom, 35);

    return Container(
        padding: EdgeInsets.fromLTRB(20, 25, 20, bottomSpace),
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                "Make sure to check a spam/junk folder.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.black)),
            SizedBox(
                height: error=='' ? 40 : 80,
                child: Center(child: Text(error, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Color(0xFFb2b2b2))))),
            Row(children: <Widget>[
              Spacer(),
              MyOutlinedButton(
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  if (deleteEmail=='Invalidate email') {
                    try {
                      widget.cancelTimer();
                      await FirebaseAuth.instance.currentUser!.delete();
                      widget.onDeleteEmail();
                      if (mounted) {
                        setState(() => deleteEmail = 'Email invalidated');
                      }
                    } on FirebaseAuthException catch (e) {
                      if (mounted) {
                        setState(() =>error = "Error: " + e.code + "\nPlease contact us at team@getconvo.app for support. Use this code: " + shortHash(widget.domainEmail.toLowerCase()));
                      }
                    }
                  }
                },
                gradient: Gradients.blueRed(begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: 20,
                thickness: 1.5,
                padding: EdgeInsets.symmetric(horizontal: 15),
                backgroundColor: Colors.white,
                child: Container(
                  height: 30,
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          deleteEmail,
                          style: ThemeText.quicksand(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 30),
              MyOutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Wrapper()), (Route<dynamic> route) => false);
                },
                gradient: Gradients.blueRed(begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: 20,
                thickness:1.5,
                padding: EdgeInsets.symmetric(horizontal: 15),
                backgroundColor: Colors.white,
                child: Container(
                  height: 30,
                  width: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          "Start Over",
                          style: ThemeText.quicksand(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer()
            ]),
          ],
        ));
  }
}
