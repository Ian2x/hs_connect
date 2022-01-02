import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/new_post/new_post.dart';
import 'package:hs_connect/screens/profile/profile_form.dart';
import 'package:hs_connect/screens/search/group_search.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/shared/widgets/navbar.dart';
import 'package:hs_connect/screens/profile/userProfile.dart';
import 'package:hs_connect/screens/profile/userFriend.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';


import 'package:flutter/cupertino.dart';
import 'package:hs_connect/screens/profile/profileWidget/profileForm_page.dart';
import 'package:hs_connect/screens/profile/profileWidget/appbar_widget.dart';
import 'package:hs_connect/screens/profile/profileWidget/button_widget.dart';
import 'package:hs_connect/screens/profile/profileWidget/numbers_widget.dart';
import 'package:hs_connect/screens/profile/profileWidget/profile_widget.dart';

class profile2 extends StatefulWidget {
  final profilePersonRef;

  profile2({Key? key, required this.profilePersonRef}) : super(key: key);
  
  @override
  _profile2State createState() => _profile2State();
}

class _profile2State extends State<profile2> {

  final AuthService _auth = AuthService();

  String profileUsername = '<Loading user name...>';

  String? profileImage;
  int profileGroupCount=0;
  int profileScore= 0;

  UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService();

  //  GroupsDatabaseService _groups = GroupsDatabaseService();

  void getProfileUserData() async {
    final UserData? fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.profilePersonRef);
    setState(() {
      profileUsername = fetchUserData != null ? fetchUserData.displayedName : '<Failed to retrieve user name>';
      profileImage = fetchUserData != null ? fetchUserData.image : '<Failed to retrieve user Image>';
      profileGroupCount = fetchUserData != null ? fetchUserData.userGroups.length : 0;
      profileScore = fetchUserData != null ? fetchUserData.score : 0;

    });
  }


  @override
  void initState() {
    getProfileUserData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData?>(context);

    print("1 " + profileUsername);
    print(profileImage);


    final user = Provider.of<User?>(context);

    if (_auth.user == null) {
      return Authenticate();
    }

    // unnecessary?
    if (user==null) {
      return Authenticate();
    }

    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            profileImage: profileImage,
            onClicked: () async {},
          ),
          const SizedBox(height: 24),
          buildName(user),
          const SizedBox(height: 24),
          Center(child: buildEditButton()),
          const SizedBox(height: 24),
          NumbersWidget(scoreCount:profileScore, groupCount: profileGroupCount),
          const SizedBox(height: 48),
          buildIconScroll(),
          const SizedBox(height: 24),
          profileImage==null ? Text("no profile Image") : Image.network(profileImage!),
          //buildGroupTileScroll(),
        ],
      ),
      bottomNavigationBar: navbar(currentIndex: 3,),
    );
  }

  Widget buildName(User user) => Column(
    children: [
      Text(
        profileUsername,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(height: 4),
      Text(
        'DOMAINl',
        style: TextStyle(color: Colors.grey),
      )
    ],
  );

  Widget buildEditButton() => ButtonWidget(
    text: 'Edit Profile',
    onClicked: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => profileForm_Page(
          profileForm:(ProfileForm(currDisplayName: profileUsername, currImageURL: profileImage)),
        )
        )
      );
    },
  );

  Widget buildIconScroll() =>Container(
    height: 100,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        Container(
          width: 200,
          color: Colors.purple[600],
          child: const Center(child: Text('Item 1', style: TextStyle(fontSize: 18, color: Colors.white),)),
        ),
        Container(
          width: 200,
          color: Colors.purple[500],
          child: const Center(child: Text('Item 2', style: TextStyle(fontSize: 18, color: Colors.white),)),
        ),
        Container(
          width: 200,
          color: Colors.purple[400],
          child: const Center(child: Text('Item 3', style: TextStyle(fontSize: 18, color: Colors.white),)),
        ),
        Container(
          width: 200,
          color: Colors.purple[300],
          child: const Center(child: Text('Item 4', style: TextStyle(fontSize: 18, color: Colors.white),)),
        ),
      ],
    ),
  );

}
