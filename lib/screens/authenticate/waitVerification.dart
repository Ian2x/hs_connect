import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/shared/constants.dart';
import 'dart:async';
import '../wrapper.dart';

class WaitVerification extends StatefulWidget {
  final email;

  const WaitVerification({Key? key, required this.email}) : super(key: key);

  @override
  _WaitVerificationState createState() => _WaitVerificationState();
}

class _WaitVerificationState extends State<WaitVerification> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;

  bool resent = false;

  @override
  void initState() {
    user = auth.currentUser;
    user!.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 3), (timer) {
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
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Text(
                "We've sent you an email\nto verify your school",
                style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
              ),
              SizedBox(height: 20),
              Text("Make sure to check your spam folder.",
                  style:
                      Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.black, height: 1.5, fontSize: 18)),
              SizedBox(height: 85),
              Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "Email info is for verification only. We will never release user data.",
                  style: ThemeText.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(resent != true ? "Didn't get it? " : "Resent email: ",
                      style: ThemeText.quicksand(
                        fontSize: 15,
                        color: Colors.black,
                      )),
                  GestureDetector(
                      onTap: () {
                        if (!resent) {
                          HapticFeedback.heavyImpact();
                          user!.sendEmailVerification();
                          setState(() {
                            resent = true;
                          });
                        }
                      },
                      child: Text(resent != true ? "Click here to resend" : "Check your spam/junk folder.",
                          style: ThemeText.quicksand(
                            fontSize: 15,
                            color: Colors.black,
                            decoration: resent != true ? TextDecoration.underline : null,
                          ))),
                ],
              ),
              SizedBox(height: max(MediaQuery.of(context).padding.bottom, 25))
            ],
          ),
        ));
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user!.reload();
    if (user!.emailVerified) {
      timer!.cancel();
      Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Wrapper()), (Route<dynamic> route) => false);
    }
  }
}
