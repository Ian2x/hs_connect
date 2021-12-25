import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/authenticate/wait_verification.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:provider/provider.dart';


class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);

    print(user == null || !user.email!.endsWith('@ianeric.com'));
    print(user);
    print(userData);

    if (user == null || !user.email!.endsWith('@ianeric.com')) {
      print("AUTHENTICATE");
      return Authenticate();
    } else {
      print("HOME");
      return Home();
    }
  }
}
