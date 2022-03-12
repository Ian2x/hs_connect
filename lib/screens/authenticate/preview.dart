import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/registerEmail.dart';
import 'package:hs_connect/screens/authenticate/signIn.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chooseSchool.dart';
import 'registerNumber.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: 180),
              SizedBox(
                height: 75,
                child: Image.asset('assets/Splash2.png'),
              ),
              SizedBox(height: 55),
              Text("convo",
                  style: textTheme.headline4?.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 33, fontFamily: "Shippori")),
              SizedBox(height: 15),
              Text(
                "Talk anonymously,",
                style: textTheme.subtitle1?.copyWith(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
              ),
              SizedBox(height: 4),
              Text(
                "Talk openly",
                style: textTheme.subtitle1?.copyWith(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
              ),
              SizedBox(height: 100),
              ActionChip(
                padding: EdgeInsets.fromLTRB(60, 15, 60, 15),
                backgroundColor: Colors.black,
                label: Text(
                  'Sign up',
                  style: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChooseSchool()));
                },
              ),
              SizedBox(height: 15),
              TextButton(
                child: Text(
                  "Login",
                  style: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignIn()));
                },
              ),
              Spacer(),
              RichText(
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  text: TextSpan(style: textTheme.caption?.copyWith(color: Colors.black), children: [
                    TextSpan(text: "By using Convo you agree to Convo's "),
                    TextSpan(
                        text: "Terms\nof Service",
                        style: textTheme.caption?.copyWith(color: Color(0xFF13a1f0), fontWeight: FontWeight.w600),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () async {
                            if (await canLaunch('https://www.getconvo.app/terms')) {
                              await launch('https://www.getconvo.app/terms');
                            }
                          }),
                    TextSpan(text: ", "),
                    TextSpan(
                        text: "Content Policy",
                        style: textTheme.caption?.copyWith(color: Color(0xFF13a1f0), fontWeight: FontWeight.w600),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () async {
                            if (await canLaunch('https://www.getconvo.app/content')) {
                              await launch('https://www.getconvo.app/content');
                            }
                          }),
                    TextSpan(text: ", and "),
                    TextSpan(
                        text: "Privacy Policy",
                        style: textTheme.caption?.copyWith(color: Color(0xFF13a1f0), fontWeight: FontWeight.w600),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () async {
                            if (await canLaunch('https://www.getconvo.app/privacy')) {
                              await launch('https://www.getconvo.app/privacy');
                            }
                          })
                  ])),
              SizedBox(height: max(10, MediaQuery.of(context).padding.bottom)),
            ],
          )),
    );
  }
}
