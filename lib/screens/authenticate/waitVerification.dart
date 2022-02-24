import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/registerUser.dart';
import 'package:hs_connect/shared/constants.dart';
import 'dart:async';

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 30),
            Center(
                child: Column(
              children: [
                SizedBox(
                  height: 80,
                  child: Image.asset('assets/Splash2.png'),
                ),
                SizedBox(height: 20),
                Text(
                  'We sent you a link',
                  style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 24, color: Colors.black),
                ),
                SizedBox(height: 15),
                Center(
                  child: Text("Click the link in your school email.\nWait a bit to be redirected afterwards.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          ?.copyWith(color: Colors.black, height: 1.5)),
                ),
                SizedBox(height: 85),
                Container(
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(
                    gradient: Gradients.blueRed(begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.5),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.all(1.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Your email is for verification only. It'll never be linked to your account.",
                          style: ThemeText.quicksand(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                            color: Colors.black,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 190),
                Center(
                  child: Text("Make sure to check your spam/junk folder.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          ?.copyWith(color: Colors.black, height: 1.5)),
                ),
              ],
            )),
          ]),
        ]));
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user!.reload();
    if (user!.emailVerified) {
      timer!.cancel();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              RegisterUser(domain: widget.domain, domainEmail: widget.domainEmail)));
    }
  }
}
