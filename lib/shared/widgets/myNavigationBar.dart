import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/activityPage.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/new/newPost/newPost.dart';
import 'package:hs_connect/screens/profile/profilePage.dart';
import 'package:hs_connect/services/my_notifications_database.dart';
import 'package:hs_connect/shared/widgets/thickerIcons.dart';
import 'package:provider/provider.dart';

import '../../models/myNotification.dart';
import '../../services/user_data_database.dart';
import '../constants.dart';
import '../pageRoutes.dart';

import 'loading.dart';

class MyNavigationBar extends StatefulWidget {
  final int currentIndex;
  final UserData currUserData;
  final int? overrideNumNotifications;

  const MyNavigationBar(
      {Key? key, required this.currentIndex, required this.currUserData, this.overrideNumNotifications})
      : super(key: key);

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (loading || userData == null) return Loading();

    return Stack(
      children: [
        Container(
          color: userData.domainColor ?? colorScheme.onSurface,
          padding: EdgeInsets.only(top: bottomGradientThickness),
          child: Container(
            color: colorScheme.surface,
            height: 45 + MediaQuery.of(context).padding.bottom,
            child: BottomNavigationBar(
              backgroundColor: colorScheme.surface,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: widget.currentIndex,
              selectedItemColor: colorScheme.onSurface,
              selectedFontSize: 1,
              unselectedFontSize: 1,
              onTap: (int index) async {
                if (index == 0 && user != null) {
                  if (widget.currentIndex == 0) {
                    // Do nothing
                  } else {
                    Navigator.pop(context);
                  }
                } else if (index == 1) {
                  if (widget.currentIndex == 0) {
                    Navigator.push(
                      context,
                      NoAnimationMaterialPageRoute(
                          builder: (context) => ActivityPage(
                                userData: userData,
                              )),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      NoAnimationMaterialPageRoute(
                          builder: (context) => ActivityPage(
                                userData: userData,
                              )),
                    );
                  }
                } else if (index == 2) {
                  if (widget.currentIndex == 0) {
                    Navigator.push(
                      context,
                      NoAnimationMaterialPageRoute(builder: (context) => ProfilePage(currUserData: userData)),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      NoAnimationMaterialPageRoute(builder: (context) => ProfilePage(currUserData: userData)),
                    );
                  }
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    NoAnimationMaterialPageRoute(builder: (context) => NewPost()),
                  );
                }
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(label: '', icon: Icon(Thicker.home_square, size: 25)),
                BottomNavigationBarItem(label: '', icon: Icon(Thicker.notification, size: 25)),
                BottomNavigationBarItem(label: '', icon: Icon(Thicker.profile_1, size: 20)),
                BottomNavigationBarItem(label: '', icon: Icon(Thicker.add_1, size: 25)),
              ],
            ),
          ),
        ),
        Positioned(
            left: MediaQuery.of(context).size.width * 0.375 + 1.5,
            top: 5.5,
            child: IgnorePointer(
              child: StreamBuilder(
                  stream: UserDataDatabaseService(currUserRef: widget.currUserData.userRef).userData,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    } else {
                      UserData? streamData = (snapshot.data as UserData?);
                      if (streamData == null) {
                        return Container();
                      } else {
                        return FutureBuilder(
                            future:
                            MyNotificationsDatabaseService(userRef: widget.currUserData.userRef).getNotifications(),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              } else {
                                List<MyNotification> streamNotifications = snapshot.data;
                                final numActivity = streamNotifications
                                    .where(
                                        (element) => element.createdAt.compareTo(widget.currUserData.notificationsLastViewed) > 0)
                                    .length;
                                final numMessages = streamData.userMessages
                                    .where((element) =>
                                element.lastViewed == null ||
                                    (element.lastViewed != null && element.lastMessage.compareTo(element.lastViewed!) > 0))
                                    .length;
                                final testNumNotifications = numActivity + numMessages;
                                if (testNumNotifications == 0) {
                                  return Container();
                                }
                                return Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(1.5),
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(2.5, 2, 2, 2),
                                      decoration: BoxDecoration(
                                        color: userData.domainColor ?? colorScheme.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: FittedBox(
                                        child: Text(testNumNotifications.toString(),
                                            style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Colors.white)),
                                      )),
                                );
                              }
                            });
                      }
                    }
                  }),
            ))
      ],
    );
  }
}
