import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/messages/allMessagesPage.dart';
import 'package:hs_connect/screens/activity/notifications/notificationsFeed.dart';
import 'package:hs_connect/screens/home/homeAppBar.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

import 'activityAppBar.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool isNotifications = true;

  @override
  void initState() {
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
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
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
      ),
    );
  }
}
