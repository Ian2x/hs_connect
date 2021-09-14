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
import 'package:hs_connect/screens/home/profile/editProfilePage.dart';
import 'package:hs_connect/tools/HexColor.dart';


class Profile extends StatefulWidget {

  final profileId;

  Profile({Key? key, required this.profileId}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {


  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData?>(context);
    bool editPrivilege= false;

    if (user.uid==widget.profileId){
      editPrivilege=true;
    }

      return Scaffold(
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
          physics: BouncingScrollPhysics(),
          children: [
            ProfileWidget(
              imagePath: "data:image/png;base64,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",
              onClicked: () async {},
              editPrivilege: editPrivilege,
            ),
            const SizedBox(height: 24),
            buildName(userData != null ? userData.displayedName : 'username',
                      userData != null ? userData.domain: 'domainName'),
            const SizedBox(height: 24),
            Center(child: buildUpgradeButton(editPrivilege, context)),
            const SizedBox(height: 24),
            NumbersWidget(),
            const SizedBox(height: 48),
            buildAbout()
          ],
        ),
        bottomNavigationBar: OGnavbar(),
      );
    }
  }

  Widget buildName(String displayedName, String domainName) => Column(

  children: [
      Text(
        displayedName,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(height: 4),
      Text(
        domainName,
        style: TextStyle(color: Colors.grey),
      )
    ],
  );

  Widget buildUpgradeButton(bool editPrivilege,BuildContext context){

    return ButtonWidget(
      text: editPrivilege ? 'Edit Profile': 'Message',
      onClicked:
        editPrivilege ? (){Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => editProfilePage()),
        );}:(){}
        //TODO: Need to Have DM Form
      ,
    );
  }

    Widget buildAbout() => Container(
      padding: EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Groups',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            "user about",
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );


