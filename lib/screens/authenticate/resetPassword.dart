import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';
import '../../shared/widgets/loading.dart';
import '../../shared/widgets/myBackButtonIcon.dart';
import 'authButton.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final AuthService _auth = AuthService();

  // text field state
  String email = '';
  String? error;
  bool loading = false;
  bool emailSent = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return loading
        ? Loading(
            backgroundColor: Colors.white,
            spinColor: Colors.black,
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: emailSent ? null : myBackButtonIcon(context, overrideColor: Colors.black),
            ),
            body: emailSent
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Reset email sent',
                        style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Check your inbox.",
                        style: textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 18, height: 1.3),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 100),
                    Container(
                      width: 360,
                      child: AuthButton(
                          buttonText: "Back",
                          hasText: true,
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                    ),
                    SizedBox(height: 50),
                  ],
                )
                : Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 60),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Your school email is...',
                                style:
                                    ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.only(left: 20),
                                child: TextField(
                                  autofocus: true,
                                  autocorrect: false,
                                  style: textTheme.headline6?.copyWith(color: authPrimaryTextColor, fontSize: 25),
                                  maxLines: null,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      hintStyle: textTheme.headline6?.copyWith(color: authHintTextColor, fontSize: 25),
                                      border: InputBorder.none,
                                      hintText: "convo@school.org"),
                                  onChanged: (value) {
                                    if (mounted) {
                                      setState(() {
                                        email = value.trim();
                                      });
                                    }
                                  },
                                )),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.topLeft,
                              child: Text(
                                error ?? "We'll send you an email to reset your password.",
                                style: textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 14, height: 1.3),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(height: 160)
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: MediaQuery.of(context).size.width * 0.5 - 180,
                        width: 360,
                        child: AuthButton(
                            buttonText: "Reset",
                            hasText: email != "",
                            onPressed: () async {
                              if (EmailValidator.validate(email)) {
                                if (mounted) {
                                  setState(() => loading = true);
                                }
                                final result = await _auth.resetPassword(email);
                                if (result == null) {
                                  if (mounted) {
                                    setState(() {
                                      loading = false;
                                      emailSent = true;
                                    });
                                  }
                                } else if (result is FirebaseAuthException) {
                                  if (mounted) {
                                    setState(() {
                                      loading = false;
                                      error = result.message;
                                    });
                                  }
                                } else {
                                  if (mounted) {
                                    setState(() {
                                      loading = false;
                                      error = result.toString();
                                    });
                                  }
                                }
                              } else {
                                if (mounted) {
                                  setState(() => error = "Please enter a valid email.");
                                }
                              }
                            }),
                      ),
                    ],
                  ),
          );
  }
}
