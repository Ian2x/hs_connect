import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';
import 'package:hs_connect/shared/widgets/outlineButton.dart';
import 'package:provider/provider.dart';

import '../wrapper.dart';

class EmailVerificationErrorSheet extends StatefulWidget {
  final VoidFunction cancelTimer;
  const EmailVerificationErrorSheet({Key? key, required this.cancelTimer}) : super(key: key);

  @override
  _EmailVerificationErrorSheetState createState() => _EmailVerificationErrorSheetState();
}

class _EmailVerificationErrorSheetState extends State<EmailVerificationErrorSheet> {
  String error = '';

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<HeightPixel>(context).value;

    return Container(
        padding: EdgeInsets.symmetric(vertical: 38*hp, horizontal: 30*wp),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Text(
                "If you haven't received an email after 5 minutes, it is recommended that you delete your email from our systems and start over. Otherwise, you'll never be able to make an account from this address. Please contact us at ___ if you still have questions.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2),
            SizedBox(
                height: 60*hp,
                child: Center(child: Text(error))),
            Row(children: <Widget>[
              Spacer(),
              MyOutlinedButton(
                onPressed: () async {
                  try {
                    widget.cancelTimer();
                    await FirebaseAuth.instance.currentUser!.delete();
                  } on FirebaseAuthException catch (e) {
                    if (mounted) {
                      setState(() {
                        error = "Error: " + e.code;
                      });
                    }
                  }
                },
                gradient: Gradients.blueRed(begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: 20*hp,
                thickness: 1.5*hp,
                child: Container(
                  height: 30*hp,
                  width: 110*hp,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientText(
                        "Delete email",
                        style: ThemeText.inter(fontWeight: FontWeight.w600, fontSize: 16*hp,
                        ),
                        gradient: Gradients.blueRed(),
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
                child: Container(
                  height: 30*hp,
                  width: 110*hp,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientText(
                        "Start Over",
                        style: ThemeText.inter(fontWeight: FontWeight.w600, fontSize: 16*hp,
                        ),
                        gradient: Gradients.blueRed(),
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
