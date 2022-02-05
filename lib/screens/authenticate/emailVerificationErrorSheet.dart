import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';
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
      deleteEmail = 'Email deleted';
    } else {
      deleteEmail = 'Delete email';
    }
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<HeightPixel>(context).value;

    return Container(
        padding: EdgeInsets.symmetric(vertical: 38*hp, horizontal: 30*wp),
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Text(
                "If you haven't received an email after 5 minutes, it is recommended that you delete your email from our systems and start over. Otherwise, you'll never be able to make an account from this address. Please contact us at app@getcircles.co if you still have questions.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.black)),
            SizedBox(
                height: 60*hp,
                child: Center(child: Text(error, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Color(0xFFb2b2b2))))),
            Row(children: <Widget>[
              Spacer(),
              MyOutlinedButton(
                onPressed: () async {
                  if (deleteEmail=='Delete email') {
                    try {
                      widget.cancelTimer();
                      await FirebaseAuth.instance.currentUser!.delete();
                      widget.onDeleteEmail();
                      if (mounted) {
                        setState(() => deleteEmail = 'Email deleted');
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
                backgroundColor: Colors.white,
                child: Container(
                  height: 40*hp,
                  width: 140*hp,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientText(
                        deleteEmail,
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
                backgroundColor: Colors.white,
                child: Container(
                  height: 40*hp,
                  width: 140*hp,
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
