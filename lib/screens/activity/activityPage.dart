import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/messages/allMessagesPage.dart';
import 'package:hs_connect/screens/activity/notifications/notificationsFeed.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';

import 'activityAppBar.dart';

class ActivityPage extends StatefulWidget {
  final UserData userData;

  const ActivityPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool isNotifications = true;
  late int numNotifications;

  @override
  void initState() {
    UserDataDatabaseService(currUserRef: widget.userData.userRef).updateNotificationsLastViewed();
    getInitialNumNotifications();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (mounted) {
        setState(() => isNotifications = tabController.index == 0);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void getInitialNumNotifications() {
    numNotifications = widget.userData.userMessages
        .where((element) =>
            element.lastViewed == null ||
            (element.lastViewed != null && element.lastMessage.compareTo(element.lastViewed!) > 0))
        .length;
  }

  void setNumNotifications(int newNum) {
    if (mounted) {
      setState(() {
        numNotifications = newNum;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: activityAppBar(
          context: context,
          tabController: tabController,
          currUserData: widget.userData),
      body: Container(
        color: colorScheme.background,
        child: TabBarView(children: <Widget>[
          NotificationsFeed(currUserData: widget.userData),
          AllMessagesPage(currUserData: widget.userData, setNumNotifications: setNumNotifications)
        ], controller: tabController, physics: BouncingScrollPhysics()),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 1,
        currUserData: widget.userData,
        overrideNumNotifications: numNotifications,
      ),
    );
  }
}
