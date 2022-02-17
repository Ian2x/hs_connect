import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/my_notifications_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

import 'notificationCard.dart';

class NotificationsFeed extends StatefulWidget {
  final UserData userData;

  const NotificationsFeed({Key? key, required this.userData}) : super(key: key);

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

  void fetchNotifications() async {
    final notificationss = await MyNotificationsDatabaseService(userRef: widget.userData.userRef).getNotifications();
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
    final hp = Provider.of<HeightPixel>(context).value;

    int numberNotifications = notifications!.length;

    if (numberNotifications == 0) {
      return Container(
          padding: EdgeInsets.only(top: 50*hp),
          alignment: Alignment.topCenter,
          child: Text("No notifications",
              style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.normal)));
    }

    return ListView.builder(
        itemCount: numberNotifications,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          int trueIndex = numberNotifications - index - 1;
          if (widget.userData.blockedUserRefs.contains(notifications![trueIndex].sourceUserRef)) {
            return Container();
          }
          if (trueIndex == numberNotifications-1) {
            return Container(
                padding: EdgeInsets.only(top: 2.5*hp),
                child: NotificationCard(myNotification: notifications![trueIndex]));
          } else if (trueIndex == 0) {
            return Container(
                padding: EdgeInsets.only(bottom: 2.5*hp),
                child: NotificationCard(myNotification: notifications![trueIndex]));
          } else {
            return NotificationCard(myNotification: notifications![trueIndex]);
          }
        });
  }
}
