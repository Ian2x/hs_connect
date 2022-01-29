import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileBody.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';

class ProfilePage extends StatelessWidget {
  final DocumentReference profileRef;
  final UserData currUserData;

  ProfilePage({Key? key, required this.profileRef, required this.currUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (profileRef==currUserData.userRef) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: ProfileBody(profileUserRef: profileRef, currUserData: currUserData,),
        bottomNavigationBar: MyNavigationBar(
          currentIndex: 2,
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(backgroundColor: colorScheme.surface, leading: myBackButtonIcon(context)),
        backgroundColor: colorScheme.surface,
        body: ProfileBody(profileUserRef: profileRef, currUserData: currUserData,),
      );
    }
  }
}
