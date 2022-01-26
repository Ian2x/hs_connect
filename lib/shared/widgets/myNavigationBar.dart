import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/activity/activityPage.dart';
import 'package:hs_connect/screens/profile/profilePage.dart';
import 'package:provider/provider.dart';

import '../pageRoutes.dart';

import '../pixels.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final hp = Provider.of<HeightPixel>(context).value;

    if (loading || userData == null) return Loading();

    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: colorScheme.primary, spreadRadius: 0.4*hp)]),
      child: BottomNavigationBar(
        backgroundColor: colorScheme.surface,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: widget.currentIndex,
        selectedItemColor: colorScheme.onSurface,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: colorScheme.onSurface,
              constraints: BoxConstraints(),
              icon: Icon(Icons.school, size: 18*hp),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) => pixelProvider(context, child: Home())),
                );
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: colorScheme.onSurface,
              constraints: BoxConstraints(),
              icon: Icon(Icons.notifications, size: 18*hp),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) => pixelProvider(context, child: ActivityPage())),
                );
              },
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: colorScheme.onSurface,
              constraints: BoxConstraints(),
              icon: Icon(Icons.person, size: 18*hp),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) => pixelProvider(context,
                          child: ProfilePage(profileRef: userData.userRef, currUserRef: userData.userRef))),
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
