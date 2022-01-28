import 'package:hs_connect/screens/authenticate/preview.dart';
import 'package:hs_connect/screens/authenticate/registerEmail.dart';
import 'package:hs_connect/screens/authenticate/signIn.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  void toggleView() {
    if (mounted) {
      setState(() => showSignIn = !showSignIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return previewPage(toggleView: toggleView);
    } else {
      return RegisterEmail(toggleView: toggleView);
    }
  }
}
