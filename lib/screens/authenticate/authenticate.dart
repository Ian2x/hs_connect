import 'package:hs_connect/screens/authenticate/register_email.dart';
import 'package:hs_connect/screens/authenticate/sign_in.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {

    if(showSignIn) {
      return SignIn(toggleView: toggleView);
    } else {
      return RegisterEmail(toggleView: toggleView);
    }
  }
}
