import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/registerUser.dart';
import 'dart:async';

import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

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

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              height: 625*hp,
              width: 314*hp,
              decoration: new BoxDecoration(
                color: ThemeColor.secondaryBlue,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 703*hp),
            Text("Make your Account", style: ThemeText.inter(fontSize: 23*hp,
              fontWeight: FontWeight.w700,
              color: ThemeColor.black,
            )),
            SizedBox(height:15*hp),
            Text('Register with your school email.',
                style: ThemeText.regularSmall(fontSize: 16*hp, color: ThemeColor.secondaryBlue)),
            SizedBox(height: 39*hp),
          ],
        ),
      ),
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
