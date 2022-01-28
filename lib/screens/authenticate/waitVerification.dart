import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/registerUser.dart';
import 'package:hs_connect/shared/constants.dart';
import 'dart:async';

import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
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
            TextButton(
                onPressed: (){
                },
                child:Text(
                  "Cancel",
                  style: ThemeText.inter(fontWeight: FontWeight.normal,
                      fontSize: 16*hp, color: Colors.grey),
                )
            ),
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
                SizedBox(height: 20*hp),
                Text(
                  'We sent you a link',
                  style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 28*hp, color: Colors.black //TODO: Convertto HP
                  ),
                ),
                SizedBox(height:20*hp),
                Center(
                  child:Text("Check your school email to verify your account.",
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.onSurface, fontSize: 14)),
                ),
                SizedBox(height:5*hp),
                Center(
                  child:Text("This info is never shown.",
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.onSurface, fontSize: 14)),
                ),
                /*GradientText(
                        'Sign up',
                        style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 28*hp, //TODO: Convertto HP
                        ),
                        gradient: Gradients.blueRed(),
                      ),  */                          SizedBox(height:15*hp),
                SizedBox(height: 50*hp),
              ],
            )
          ),
      ]),
            Positioned(
              bottom:0,
              left:0,
              child: AuthBar(buttonText: "Register",
                  onPressed: () async {
                  }),
            ),
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
