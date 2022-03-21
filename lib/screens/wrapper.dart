import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:provider/provider.dart';
import 'authenticate/preview.dart';
import 'home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);


    if (user == null || userData == null) {
      return PreviewPage();
    } else {
      return Home(user: user, currUserData: userData);
    }
  }
}
