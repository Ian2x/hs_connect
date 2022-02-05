import 'package:hs_connect/screens/authenticate/registerEmail.dart';
import 'package:hs_connect/screens/authenticate/signIn.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {

  final bool signIn;

  Authenticate({Key? key,required this.signIn }) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  late bool showSignIn;

  void toggleView() {
    if (mounted) {
      setState(() => showSignIn = !showSignIn);
    }
  }

  @override
  void initState() {
    showSignIn= widget.signIn;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return SignIn(toggleView: toggleView);
    } else {
      return RegisterEmail(toggleView: toggleView);
    }
  }
}
