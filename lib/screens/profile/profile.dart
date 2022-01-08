import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/profile/groupCarousel.dart';
import 'package:hs_connect/screens/profile/profileForm.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/shared/widgets/navigationBar.dart';
import 'package:hs_connect/screens/profile/profileWidget/profileFormPage.dart';
import 'package:hs_connect/screens/profile/profileWidget/profileAppBar.dart';
import 'package:hs_connect/screens/profile/profileWidget/buttonWidget.dart';
import 'package:hs_connect/screens/profile/profileWidget/numbersWidget.dart';
import 'package:hs_connect/screens/profile/profileWidget/profileWidget.dart';

class Profile extends StatefulWidget {
  final DocumentReference profilePersonRef;
  final DocumentReference currUserRef;

  Profile({Key? key, required this.profilePersonRef, required this.currUserRef}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _auth = AuthService();

  String profileUsername = '<Loading user name...>';

  String? profileImage;
  int profileGroupCount = 0;
  int profileScore = 0;
  List<Group>? profileGroups;

  void getProfileUserData() async {
    UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    final UserData? fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.profilePersonRef);
    if (mounted) {
      setState(() {
        profileUsername = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
        profileImage = fetchUserData != null ? fetchUserData.profileImage : '<Failed to retrieve user Image>';
        profileGroupCount = fetchUserData != null ? fetchUserData.userGroups.length : 0;
        profileScore = fetchUserData != null ? fetchUserData.score : 0;
      });
    }
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    if (fetchUserData!=null) {
      final temp = await _groups.getGroups(userGroups: fetchUserData.userGroups);
      setState(() {
        profileGroups = temp;
      });
    }
  }

  @override
  void initState() {
    getProfileUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Authenticate();
    }
    if (profileGroups == null) {
      return Loading();
    }

    return Scaffold(
      appBar: profileAppBar(context),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          const SizedBox(height:20),
          ProfileWidget(
            profileImage: profileImage,
            onClicked: () async {},
            currUserName: profileUsername,
          ),
          const SizedBox(height: 10),
          buildName(userData),
          //const SizedBox(height: 24),
          //Center(child: buildEditButton()),
          const SizedBox(height: 5),
          NumbersWidget(scoreCount: profileScore, groupCount: profileGroupCount),
          const SizedBox(height: 20),
          Divider(thickness: 1.5),
          SizedBox(height: 10),
          buildIconScroll(),
          const SizedBox(height: 2),
        ],
      ),
      bottomNavigationBar: navigationBar(
        currentIndex: 3,
      ),
    );
  }

  Widget buildName(UserData userData) => Column(
        children: [
          Text(
            profileUsername,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(userData.domain,
            style: TextStyle(color: Colors.black),
          )
        ],
      );

  Widget buildEditButton() => ButtonWidget(
        text: 'Edit Profile',
        onClicked: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileFormPage(
                        profileForm: (ProfileForm(currDisplayName: profileUsername, currImageURL: profileImage)),
                      )));
        },
      );

  Widget buildIconScroll() => Container(
        height: 400,
        child: GroupCarousel(groups: profileGroups!)
      );
}
