import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:provider/provider.dart';

import 'authenticate/authenticate.dart';
import 'home/home2.dart';
import 'home/home.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);
    return Provider<HeightPixel>.value(
        value: HeightPixel(MediaQuery.of(context).size.height / 781.1),
        child: Provider<WidthPixel>.value(
            value: WidthPixel(MediaQuery.of(context).size.width / 392.7),
            child:
                (user == null || userData == null || !user.email!.endsWith('@ianeric.com')) ? Authenticate() : Home2(userData: userData,)));
  }
}
