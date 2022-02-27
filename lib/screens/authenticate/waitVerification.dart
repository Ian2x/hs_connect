import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/registerUser.dart';
import 'package:hs_connect/shared/constants.dart';
import 'dart:async';

import '../../shared/themeManager.dart';
import '../../shared/widgets/myBackButtonIcon.dart';

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
        resizeToAvoidBottomInset : false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: myBackButtonIcon(context, overrideColor: ThemeNotifier.lightThemeOnSurface,
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                Text(
                  'Click the link in your \nschool email',
                  style: ThemeText.quicksand(
                      fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
                ),
                SizedBox(height: 20),
                Text("Make sure to check your spam folder.",
                  style: Theme.of(context).textTheme.subtitle1
                        ?.copyWith(color: Colors.black, height: 1.5, fontSize: 18)),
                SizedBox(height: 85),
                Container(
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical:30),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(15),

                  ),
                  child: Text(
                    "Email is only for verification. It'll never be linked to your account.",
                    style: ThemeText.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 190),
              ],
            ),
          ),
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
