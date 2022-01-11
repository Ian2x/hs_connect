import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/profile/profileWidgets/groupCarousel.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileName.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileAppBar.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileStats.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';

class Profile extends StatefulWidget {
  final DocumentReference profileRef;
  final DocumentReference currUserRef;

  Profile({Key? key, required this.profileRef, required this.currUserRef}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String profileUsername = '<Loading user name...>';

  String? profileImageString;
  Widget profileImage = Loading(size: 30.0);
  int profileGroupCount = 0;
  int profileScore = 0;
  List<Group>? profileGroups;

  void getProfileUserData() async {
    UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    final UserData? fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.profileRef);
    if (mounted) {
      setState(() {
        profileUsername = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
        profileImageString = fetchUserData != null ? fetchUserData.profileImage : '<Failed to retrieve user Image>';
        profileGroupCount = fetchUserData != null ? fetchUserData.userGroups.length : -1;
        profileScore = fetchUserData != null ? fetchUserData.score : -1;
      });
    }
    if (profileImageString!='<Failed to retrieve user Image>' && profileImageString!=null) {
      var tempImage = Image.network(profileImageString!);
      tempImage.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo image, bool syncrhonousCall) {
          if (mounted) {
            setState(() => profileImage = tempImage);
          }
      }));
    }
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    if (fetchUserData!=null) {
      final fetchUserGroups = await _groups.getUserGroups(userGroups: fetchUserData.userGroups);
      if (mounted) {
        setState(() {
          profileGroups = fetchUserGroups;
        });
      }
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
          SizedBox(height: 10),
          ProfileImage(
            profileImage: profileImage,
            profileImageString: profileImageString == '<Failed to retrieve user Image>' ? null : profileImageString,
            currUserName: profileUsername,
            showEditIcon: widget.profileRef==widget.currUserRef && widget.currUserRef==userData.userRef,
          ),
          SizedBox(height: 10),
          ProfileName(name: profileUsername, domain: userData.domain),
          SizedBox(height: 15),
          ProfileStats(scoreCount: profileScore, groupCount: profileGroupCount),
          SizedBox(height: 25),
          Divider(thickness: 1.5),
          SizedBox(height: 10),
          GroupCarousel(groups: profileGroups!, userAccess: Access(domain: userData.domain, county: userData.county, state: userData.state, country: userData.country)), //buildIconScroll(),
          SizedBox(height: 2),
        ],
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 3,
      ),
    );
  }
}
