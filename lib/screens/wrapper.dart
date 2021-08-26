import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/authenticate/wait_verification.dart';
import 'package:hs_connect/screens/user/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null || !user.email!.endsWith('@ianeric.com')) {
      return Authenticate();
    } else {
      return Home();
    }

    return Authenticate();
  }
}
