import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:provider/provider.dart';
import 'authenticate/preview.dart';
import 'home/home.dart';
class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);
    if (user == null || userData == null || user.email==null || !user.email!.endsWith('@ianeric.com')) {
      return pixelProvider(context, child: PreviewPage());
    } else {
      return pixelProvider(context, child: new Home(userData: userData));
    }
    //return pixelProvider(context, child: (user == null || userData == null || user.email==null || !user.email!.endsWith('@ianeric.com')) ? PreviewPage() : Home());
  }
}