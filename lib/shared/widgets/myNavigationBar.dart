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
  final UserData currUserData;

  const MyNavigationBar({Key? key, required this.currentIndex, required this.currUserData}) : super(key: key);

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  bool loading = false;
  late int numNotifications;

  @override
  void initState() {
    numNotifications = widget.currUserData.myNotifications
            .where((element) => element.createdAt.compareTo(widget.currUserData.notificationsLastViewed) > 0)
            .length +
        widget.currUserData.userMessages
            .where((element) =>
                element.lastViewed == null ||
                (element.lastViewed != null && element.lastMessage.compareTo(element.lastViewed!) > 0))
            .length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    if (loading || userData == null) return Loading();

    return Stack(
      children: [
        Container(
          color: colorScheme.onSurface,
          padding: EdgeInsets.only(top: bottomGradientThickness * hp),
          height: 43*hp,
          child: BottomNavigationBar(
            backgroundColor: colorScheme.surface,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            currentIndex: widget.currentIndex,
            selectedItemColor: colorScheme.onSurface,
            selectedFontSize: 6*hp,
            unselectedFontSize: 6*hp,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: IconButton(
                  padding: EdgeInsets.only(top: 5*hp),
                  // color: colorScheme.onSurface,
                  constraints: BoxConstraints(),
                  alignment: Alignment.bottomCenter,
                  icon: Icon(Icons.home, size: 25 * hp),
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
                  padding: EdgeInsets.only(top: 5*hp),
                  // color: colorScheme.onSurface,
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.notifications, size: 25 * hp),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      NoAnimationMaterialPageRoute(builder: (context) => pixelProvider(context, child: ActivityPage(currUserData: userData,))),
                    );
                  },
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                  padding: EdgeInsets.only(top: 5*hp),
                  // color: colorScheme.onSurface,
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.person, size: 25 * hp),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      NoAnimationMaterialPageRoute(
                          builder: (context) => pixelProvider(context,
                              child: ProfilePage(profileRef: userData.userRef, currUserData: userData)
                          )),
                    );
                  },
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                  padding: EdgeInsets.only(top: 0*hp),
                  // color: colorScheme.onSurface,
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.add, size: 30 * hp),
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
        ),
        Positioned(
            left: 148.5 * wp,
            top: 8 * hp,
            child: numNotifications!=0 ? Container(
              height: 20*hp,
              width: 20*hp,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(1.5 * hp),
              child: Container(
                  padding: EdgeInsets.fromLTRB(2.5*wp, 2*hp, 2*wp, 2.5*hp),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    child: Text(numNotifications.toString(),
                        style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Colors.white)),
                  )),
            ) : Container())
      ],
    );
  }
}
