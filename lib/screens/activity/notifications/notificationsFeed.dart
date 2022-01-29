import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/models/userData.dart';
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
  bool loading = true;

  @override
  initState() {
    // remove old notifications
    removeOldNotifications();
    super.initState();
  }

  Future _initStateHelper(MyNotification MN) async {
    if (DateTime.now().difference(MN.createdAt.toDate()).compareTo(Duration(days: notificationStorageDays)) > 0) {
      await widget.userData.userRef.update({
        C.myNotifications: FieldValue.arrayRemove([MN.asMap()])
      });
    }
  }

  void removeOldNotifications() async {
    await Future.wait([for (MyNotification MN in widget.userData.myNotifications) _initStateHelper(MN)]);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null || loading) {
      return Loading();
    }
    final hp = Provider.of<HeightPixel>(context).value;

    int numberNotifications = userData.myNotifications.length;

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
          if (trueIndex == numberNotifications-1) {
            return Container(
                padding: EdgeInsets.only(top: 2.5*hp),
                child: NotificationCard(myNotification: userData.myNotifications[trueIndex]));
          } else if (trueIndex == 0) {
            return Container(
                padding: EdgeInsets.only(bottom: 2.5*hp),
                child: NotificationCard(myNotification: userData.myNotifications[trueIndex]));
          } else {
            return NotificationCard(myNotification: userData.myNotifications[trueIndex]);
          }
        });
  }
}
