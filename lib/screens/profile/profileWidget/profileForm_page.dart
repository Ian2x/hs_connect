import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/new_post/new_post.dart';
import 'package:hs_connect/screens/profile/profile_form.dart';
import 'package:hs_connect/screens/search/group_search.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/shared/widgets/navbar.dart';
import 'package:hs_connect/screens/profile/userProfile.dart';
import 'package:hs_connect/screens/profile/userFriend.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';

class profileForm_Page extends StatelessWidget {

  ProfileForm profileForm;

  profileForm_Page({Key? key, required this.profileForm}) : super(key: key);

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body:profileForm,


    );
  }
}
