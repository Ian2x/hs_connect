import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:provider/provider.dart';
import 'authenticate/preview.dart';
import 'home/home.dart';

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
    if (user == null || userData == null || user.email==null || !user.email!.endsWith('@ianeric.com')) {
      return pixelProvider(context, child: PreviewPage());
    } else {
      return pixelProvider(context, child: Home(userData: userData));
    }
  }
}
