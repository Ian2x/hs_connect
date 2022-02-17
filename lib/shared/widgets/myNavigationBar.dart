import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/activityPage.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/home/new/newPost/newPost.dart';
import 'package:hs_connect/screens/profile/profilePage.dart';
import 'package:hs_connect/services/my_notifications_database.dart';
import 'package:hs_connect/shared/widgets/thicker_icons.dart';
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
  int? numNotifications;

  @override
  void initState() {
    getNumNotifications();
    super.initState();
  }

  void getNumNotifications() async {
    final notifications = await MyNotificationsDatabaseService(userRef: widget.currUserData.userRef).getNotifications();
    if (mounted) {
      setState(() {
        numNotifications = notifications
                .where((element) => element.createdAt.compareTo(widget.currUserData.notificationsLastViewed) > 0)
                .length +
            widget.currUserData.userMessages
                .where((element) =>
                    element.lastViewed == null ||
                    (element.lastViewed != null && element.lastMessage.compareTo(element.lastViewed!) > 0))
                .length;
      });
    }
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
          color: userData.domainColor != null ? userData.domainColor! : colorScheme.surface, //colorScheme.surface,
          padding: EdgeInsets.only(top: bottomGradientThickness * hp),
          child: Container(
            color: colorScheme.surface,
            height: 45 * hp + MediaQuery.of(context).padding.bottom,
            child: BottomNavigationBar(
              backgroundColor: colorScheme.surface,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              currentIndex: widget.currentIndex,
              selectedItemColor: colorScheme.onSurface,
              selectedFontSize: 6 * hp,
              unselectedFontSize: 6 * hp,
              onTap: (int index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    NoAnimationMaterialPageRoute(
                        builder: (context) => pixelProvider(context, child: Home(userData: userData))),
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    NoAnimationMaterialPageRoute(
                        builder: (context) => pixelProvider(context,
                            child: ActivityPage(
                              currUserData: userData,
                            ))),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    NoAnimationMaterialPageRoute(
                        builder: (context) => pixelProvider(context,
                            child: ProfilePage(currUserData: userData))),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    NoAnimationMaterialPageRoute(builder: (context) => pixelProvider(context, child: NewPost())),
                  );
                }
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(label: '', icon: Icon(Thicker.home_square, size: 30 * hp)),
                BottomNavigationBarItem(label: '', icon: Icon(Thicker.notification, size: 30 * hp)),
                BottomNavigationBarItem(label: '', icon: Icon(Thicker.profile_1, size: 30 * hp)),
                BottomNavigationBarItem(label: '', icon: Icon(Thicker.add_1, size: 30 * hp)),
              ],
            ),
          ),
        ),
        Positioned(
            left: 148.5 * wp,
            top: 5 * hp,
            child: numNotifications != null && numNotifications != 0
                ? Container(
                    height: 20 * hp,
                    width: 20 * hp,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(1.5 * hp),
                    child: Container(
                        padding: EdgeInsets.fromLTRB(2.5 * wp, 2 * hp, 2 * wp, 2.5 * hp),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          child: Text(numNotifications.toString(),
                              style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Colors.white)),
                        )),
                  )
                : Container())
      ],
    );
  }
}
