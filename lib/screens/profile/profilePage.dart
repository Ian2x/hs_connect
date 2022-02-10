import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileBody.dart';
import 'package:hs_connect/screens/profile/settings/settingsPage.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:hs_connect/shared/widgets/myDivider.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';

class ProfilePage extends StatelessWidget {
  final DocumentReference profileRef;
  final UserData currUserData;

  ProfilePage({Key? key, required this.profileRef, required this.currUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (profileRef == currUserData.userRef) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: colorScheme.surface,
            actions: [
              IconButton(
                  icon: Icon(Icons.settings, color: colorScheme.primaryVariant),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => pixelProvider(context,
                                child: SettingsPage(
                                  initialIsLightTheme: Theme.of(context).brightness == Brightness.light,
                                  currUserData: currUserData,
                                ))));
                  })
            ],
            elevation: 0),
        backgroundColor: colorScheme.surface,
        body: ProfileBody(
          profileUserRef: profileRef,
          currUserData: currUserData,
        ),
        bottomNavigationBar: MyNavigationBar(
          currentIndex: 2,
          currUserData: currUserData,
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(backgroundColor: colorScheme.surface, leading: myBackButtonIcon(context), elevation: 0),
        backgroundColor: colorScheme.surface,
        body: ProfileBody(
          profileUserRef: profileRef,
          currUserData: currUserData,
        ),
      );
    }
  }
}
