import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/my_notifications_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';

import '../../../services/user_data_database.dart';
import 'notificationCard.dart';

class NotificationsFeed extends StatefulWidget {
  final UserData currUserData;

  const NotificationsFeed({Key? key, required this.currUserData}) : super(key: key);

  @override
  _NotificationsFeedState createState() => _NotificationsFeedState();
}

class _NotificationsFeedState extends State<NotificationsFeed> {
  List<MyNotification>? notifications;

  @override
  initState() {
    fetchNotifications();
    super.initState();
  }

  Future<void> fetchNotifications() async {
    UserDataDatabaseService(currUserRef: widget.currUserData.userRef).updateNotificationsLastViewed();
    final notificationss =
        await MyNotificationsDatabaseService(userRef: widget.currUserData.userRef).getNotifications();
    if (mounted) {
      setState(() {
        notifications = notificationss;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (notifications == null) {
      return Loading();
    }

    int numberNotifications = notifications!.length;

    return RefreshIndicator(
      onRefresh: fetchNotifications,
      child: ListView.builder(
          itemCount: max(numberNotifications, 1),
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.zero,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (numberNotifications == 0) {
              return Container(
                  padding: EdgeInsets.only(top: 50),
                  alignment: Alignment.topCenter,
                  child: Text("No notifications",
                      style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.normal)));
            }
            int trueIndex = numberNotifications - index - 1;
            if (widget.currUserData.blockedUserRefs.contains(notifications![trueIndex].sourceUserRef)) {
              return Container();
            }
            if (trueIndex == numberNotifications - 1) {
              return Container(
                  padding: EdgeInsets.only(top: 2.5), child: NotificationCard(myNotification: notifications![trueIndex]));
            } else if (trueIndex == 0) {
              return Container(
                  padding: EdgeInsets.only(bottom: 2.5),
                  child: NotificationCard(myNotification: notifications![trueIndex]));
            } else {
              return NotificationCard(myNotification: notifications![trueIndex]);
            }
          }),
    );
  }
}
