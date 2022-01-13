import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/profile/profileBody.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileAppBar.dart';

class ProfilePage extends StatelessWidget {
  final DocumentReference profileRef;
  final DocumentReference currUserRef;

  ProfilePage({Key? key, required this.profileRef, required this.currUserRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppBar(context),
      body: ProfileBody(profileRef: profileRef, currUserRef: currUserRef,),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 2,
      ),
    );
  }
}
