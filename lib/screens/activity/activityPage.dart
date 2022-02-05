import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/messages/allMessagesPage.dart';
import 'package:hs_connect/screens/activity/notifications/notificationsFeed.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

import 'activityAppBar.dart';

class ActivityPage extends StatefulWidget {
  final UserData currUserData;
  const ActivityPage({Key? key, required this.currUserData}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool isNotifications = true;

  @override
  void initState() {
    UserDataDatabaseService(currUserRef: widget.currUserData.userRef).updateNotificationsLastViewed();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (mounted) {
        setState(() {
          isNotifications = tabController.index == 0;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    UserDataDatabaseService(currUserRef: widget.currUserData.userRef).updateNotificationsLastViewed();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (userData == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: Loading(),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: activityAppBar(context: context, isNotifications: isNotifications, tabController: tabController),
      body: Container(
        color: colorScheme.background,
        child: TabBarView(children: <Widget>[
            NotificationsFeed(userData: userData),
            AllMessagesPage(userData: userData)
          ], controller: tabController, physics: BouncingScrollPhysics()),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 1,
        currUserData: userData,
      ),
    );
  }
}
