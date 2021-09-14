import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/Widgets/OGnavbar.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/profile/profile_form.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/home/profile/ProfileWidgets/buttons_widget.dart';
import 'package:hs_connect/screens/home/profile/ProfileWidgets/numbers_widget.dart';
import 'package:hs_connect/screens/home/profile/ProfileWidgets/profile_widget.dart';
import 'package:hs_connect/tools/HexColor.dart';

class editProfilePage extends StatefulWidget {
  @override
  _editProfilePageState createState() => _editProfilePageState();
}

class _editProfilePageState extends State<editProfilePage> {


  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          backgroundColor: HexColor("#121212"),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          physics: BouncingScrollPhysics(),
          children: [
            ProfileForm(),
          ],
        ),
      );
  }

}
