import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/emailVerificationErrorSheet.dart';
import 'package:hs_connect/screens/authenticate/registerUser.dart';
import 'package:hs_connect/shared/constants.dart';
import 'dart:async';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';
import 'package:hs_connect/shared/widgets/myOutlinedButton.dart';
import 'package:provider/provider.dart';

class WaitVerification extends StatefulWidget {
  final domainEmail;
  const WaitVerification({Key? key, required this.domain, required this.domainEmail}) : super(key: key);

  final String domain;

  @override
  _WaitVerificationState createState() => _WaitVerificationState();
}

class _WaitVerificationState extends State<WaitVerification> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;
  bool emailDeleted = false;

  @override
  void initState() {
    user = auth.currentUser;
    user!.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;

    return Scaffold(
      backgroundColor: Colors.white,
        body: Stack(
          children: [
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
          height: 100*hp,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: Gradients.blueRed(begin: Alignment.topLeft , end: Alignment.bottomRight),
          ),
          child: SizedBox(),
        ),
        SizedBox(height: 30*hp),
        Row(
          children: [
            SizedBox(width: 10*hp),
          ],
        ),
        SizedBox(height: 30*hp),
        Center(
            child:
            Column(
              children: [
                SizedBox(
                  height: 80 *hp,
                  child:
                  Image.asset('assets/sublogo1cropped.png'),
                ),
                SizedBox(height: 15*hp),
                Text(
                  'We sent you a link',
                  style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 24*hp, color: Colors.black
                  ),
                ),
                SizedBox(height:15*hp),
                Center(
                  child:Text("Check the link in your school email.\nAfter, you'll be automatically redirected.", textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 15*hp, height: 1.5)),
                ),
                SizedBox(height:65 *hp),
                MyOutlinedButton(
                  onPressed: () {},
                  gradient: Gradients.blueRed(begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: 20.0,
                  thickness:1.5,
                  pressElevation: 0.0,
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  backgroundColor: Colors.white,
                  child: Container(
                    height: MediaQuery.of(context).size.height*.13,
                    width: MediaQuery.of(context).size.width*.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientText(
                          "Your email is for verification only.",
                          style: ThemeText.inter(fontWeight: FontWeight.w600, fontSize: 16*hp,
                          ),
                          gradient: Gradients.blueRed(),
                        ),
                        SizedBox(height:15 *hp),
                        GradientText(
                          " It'll never be linked to your account.",
                          style: ThemeText.inter(fontWeight: FontWeight.w600, fontSize: 14.8*hp,
                          ),
                          gradient: Gradients.blueRed(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height:180*hp),
                TextButton(
                  onPressed:(){
                    showModalBottomSheet(
                        context: context,
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20*hp),
                            )),
                        builder: (context) => pixelProvider(context, child: EmailVerificationErrorSheet(
                          cancelTimer: ()=>timer!.cancel(),
                          onDeleteEmail: () {
                            if (mounted) {
                              setState(()=>emailDeleted = true);
                            }
                          },
                          emailDeleted: emailDeleted,
                          domainEmail: widget.domainEmail
                        )));
                  },
                  child: Text(
                      " Didn't get it? Click here.",
                      style: ThemeText.inter(fontWeight: FontWeight.normal,
                        fontSize: 15*hp, color: Colors.black,
                      )
                  ),
                ),
              ],
            )
          ),
      ]),
    ])
  );
}

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user!.reload();
    if (user!.emailVerified) {
      timer!.cancel();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => pixelProvider(context, child: RegisterUser(domain: widget.domain, domainEmail: widget.domainEmail))));
    }
  }
}
