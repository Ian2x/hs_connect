import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/registerUser.dart';
import 'package:hs_connect/shared/constants.dart';
import 'dart:async';

import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';
import 'package:hs_connect/shared/widgets/outlineButton.dart';
import 'package:provider/provider.dart';

import 'authBar.dart';

class WaitVerification extends StatefulWidget {
  const WaitVerification({Key? key, required this.domain}) : super(key: key);

  final String domain;

  @override
  _WaitVerificationState createState() => _WaitVerificationState();
}

class _WaitVerificationState extends State<WaitVerification> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
        body: Stack(
          children: [

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
          height: 110*hp,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: Gradients.blueRed(begin: Alignment.topLeft , end: Alignment.bottomRight),
          ),
          child: SizedBox(),
        ),
        SizedBox(height: 10*hp),
        Row(
          children: [
            SizedBox(width: 10*hp),
            /*TextButton(
                onPressed: (){
                },
                child:Text(
                  "Cancel",
                  style: ThemeText.inter(fontWeight: FontWeight.normal,
                      fontSize: 16*hp, color: Colors.grey),
                )
            ),*/
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
                  Image.asset('assets/logo1background.png'),
                ),
                SizedBox(height: 15*hp),
                Text(
                  'We sent you a link',
                  style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 24*hp, color: Colors.black //TODO: Convertto HP
                  ),
                ),
                SizedBox(height:15*hp),
                Center(
                  child:Text("Check the link in your school email.",
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.onSurface, fontSize: 16)),
                ),
                SizedBox(height:65 *hp),
                MyOutlinedButton(  //TODO: Add Gmail LInk
                  onPressed: () {},
                  gradient: Gradients.blueRed(begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: 20.0,
                  thickness:1.5,
                  child: Container(
                    height: MediaQuery.of(context).size.height*.13,
                    width: MediaQuery.of(context).size.width*.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientText(
                          "Your email is for verification only.",
                          style: ThemeText.inter(fontWeight: FontWeight.w600, fontSize: 16*hp, //TODO: Convertto HP
                          ),
                          gradient: Gradients.blueRed(),
                        ),
                        SizedBox(height:15 *hp),
                        GradientText(
                          " It'll never be linked to your account.",
                          style: ThemeText.inter(fontWeight: FontWeight.w600, fontSize: 14.8*hp, //TODO: Convertto HP
                          ),
                          gradient: Gradients.blueRed(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height:245*hp),
                TextButton(
                  onPressed:(){}, //TODO: Resend Email
                  child:Text(
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
          .push(MaterialPageRoute(builder: (context) => pixelProvider(context, child: RegisterUser(domain: widget.domain))));
    }
  }
}
