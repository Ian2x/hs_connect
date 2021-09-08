import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/models/user_data.dart';
import 'package:hs_connect/Backend/screens/authenticate/authenticate.dart';
import 'package:hs_connect/Backend/screens/authenticate/wait_verification.dart';
import 'package:hs_connect/Backend/screens/home/home.dart';
import 'package:hs_connect/Backend/services/userInfo_database.dart';
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


    if (user == null || !user.email!.endsWith('@ianeric.com')) {
      return Authenticate();
    } else {
      return Home();
    }

    return Authenticate();
  }
}
