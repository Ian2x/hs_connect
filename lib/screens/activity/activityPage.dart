import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/messages/allMessagesPage.dart';
import 'package:hs_connect/screens/activity/notifications/notificationsFeed.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/loading.dart';
import 'activityAppBar.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userData = Provider.of<UserData?>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: activityAppBar(context: context, tabController: tabController, currUserData: userData),
      body: userData == null ? Loading() : Container(
        color: colorScheme.surface,
        child: TabBarView(children: <Widget>[
          NotificationsFeed(currUserData: userData),
          AllMessagesPage(currUserData: userData)
        ], controller: tabController, physics: AlwaysScrollableScrollPhysics()),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 1,
      ),
    );
  }
}