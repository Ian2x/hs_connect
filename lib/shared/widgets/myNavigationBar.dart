import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/activityPage.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/home/new/newPost/newPost.dart';
import 'package:hs_connect/screens/profile/profilePage.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
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
      decoration: BoxDecoration(
        gradient: Gradients.blueRed(
          begin: Alignment.bottomLeft, end: Alignment.topRight,
        ),
      ),
      padding: EdgeInsets.only(top: bottomGradientThickness*hp),
      child: BottomNavigationBar(
        backgroundColor: colorScheme.surface,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: widget.currentIndex,
        selectedItemColor: colorScheme.onSurface,
        selectedFontSize: 6,
        unselectedFontSize: 6,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.green,
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: colorScheme.onSurface,
              constraints: BoxConstraints(),
              icon: Icon(Icons.home, size: 25*hp),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) => pixelProvider(context, child: Home(userData: userData))),
                );
              },
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: colorScheme.onSurface,
              constraints: BoxConstraints(),
              icon: Icon(Icons.notifications, size: 25*hp),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) => pixelProvider(context, child: ActivityPage())),
                );
              },
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: colorScheme.onSurface,
              constraints: BoxConstraints(),
              icon: Icon(Icons.person, size: 25*hp),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) => pixelProvider(context,
                          child: ProfilePage(profileRef: userData.userRef, currUserData: userData))),
                );
              },
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              // color: colorScheme.onSurface,
              constraints: BoxConstraints(),
              icon: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return Gradients.blueRed().createShader(bounds);
                },
                child: Icon(Icons.add, size: 30*hp, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pixelProvider(context, child: NewPost())),
                );
              },
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
