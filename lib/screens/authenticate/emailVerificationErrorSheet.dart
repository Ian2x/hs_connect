import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/myOutlinedButton.dart';
import 'package:provider/provider.dart';

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
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<HeightPixel>(context).value;

    final bottomSpace = max(MediaQuery.of(context).padding.bottom, 35*hp);

    return Container(
        padding: EdgeInsets.fromLTRB(20*wp, 25*hp, 20*wp, bottomSpace),
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                "If you haven't received an email after 2 minutes, it is recommended that you invalidate the email from our systems and start over. Otherwise, you'll never be able to make an account from this address. Please contact us at app@getcircles.co if you still have questions.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.black)),
            SizedBox(
                height: error=='' ? 40*hp : 80*hp,
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
                        setState(() =>error = "Error: " + e.code + "\nPlease contact us at app@getcircles.co for support. Use this code: " + shortHash(widget.domainEmail.toLowerCase()));
                      }
                    }
                  }
                },
                gradient: Gradients.blueRed(begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: 20*hp,
                thickness: 1.5*hp,
                padding: EdgeInsets.symmetric(horizontal: 15*wp),
                backgroundColor: Colors.white,
                child: Container(
                  height: 30*hp,
                  width: 100*wp,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          deleteEmail,
                          style: ThemeText.inter(fontWeight: FontWeight.w600, fontSize: 16*hp, color: Colors.black
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 30*wp),
              MyOutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => pixelProvider(context, child: Wrapper())), (Route<dynamic> route) => false);
                },
                gradient: Gradients.blueRed(begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: 20*hp,
                thickness:1.5*hp,
                padding: EdgeInsets.symmetric(horizontal: 15*wp),
                backgroundColor: Colors.white,
                child: Container(
                  height: 30*hp,
                  width: 70*wp,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          "Start Over",
                          style: ThemeText.inter(fontWeight: FontWeight.w600, fontSize: 16*hp, color: Colors.black
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
