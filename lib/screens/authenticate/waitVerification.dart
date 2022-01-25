import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/registerUser.dart';
import 'dart:async';

import 'package:hs_connect/shared/constants.dart';

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

    double unit = MediaQuery.of(context).size.height/10;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              height: unit*.8,
              width: unit * .8,
              decoration: new BoxDecoration(
                color: ThemeColor.secondaryBlue,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: unit*.9),
            Text("Make your Account", style: ThemeText.inter(fontSize: 23,
              fontWeight: FontWeight.w700,
              color: ThemeColor.black,
            )),
            SizedBox(height:15),
            Text('Register with your school email.',
                style: ThemeText.regularSmall(fontSize: 16, color: ThemeColor.secondaryBlue)),
            SizedBox(height: unit/2),
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
          .push(MaterialPageRoute(builder: (context) => RegisterUser(domain: widget.domain)));
    }
  }
}
