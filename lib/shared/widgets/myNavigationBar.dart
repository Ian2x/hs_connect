import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/home/new/newPost/newPost.dart';
import 'package:hs_connect/screens/notifications/notificationsPage.dart';
import 'package:hs_connect/screens/profile/profile.dart';
import 'package:hs_connect/screens/search/searchPage.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../noAnimationMaterialPageRoute.dart';

import 'loading.dart';

class MyNavigationBar extends StatefulWidget {
  final int currentIndex;

  const MyNavigationBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (loading || userData == null) return Loading();

    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: HexColor("#FFFFFF"), spreadRadius: 1.0)]),
      child: BottomNavigationBar(
        backgroundColor: HexColor("#FFFFFF"),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        // <-- HERE
        showUnselectedLabels: false,
        currentIndex: widget.currentIndex,
        selectedItemColor: ThemeColor.black,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: ThemeColor.black,
              constraints: BoxConstraints(),
              icon: Icon(Icons.school, size: 18.0),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: ThemeColor.black,
              constraints: BoxConstraints(),
              icon: Icon(Icons.search_rounded, size: 18.0),
              onPressed: () async {
                if (mounted) {
                  setState(() {
                    loading = true;
                  });
                }
                Navigator.pushReplacement(
                    context,
                    NoAnimationMaterialPageRoute(
                      builder: (context) => SearchPage(),
                    ));
              },
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: ThemeColor.black,
              constraints: BoxConstraints(),
              icon: Icon(Icons.notifications, size: 18.0),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: ThemeColor.black,
              constraints: BoxConstraints(),
              icon: Icon(Icons.person, size: 18.0),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(builder: (context) => Profile(profileRef: userData.userRef, currUserRef: userData.userRef)),
                );
              },
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
