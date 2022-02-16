import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

List<DocumentReference> docRefList(dynamic input) {
  return (input as List).map((item) => item as DocumentReference).toList();
}

List<String> stringList(dynamic input) {
  return (input as List).map((item) => item as String).toList();
}

List<CountAtTime> countAtTimeList(dynamic input) {
  return (input as List).map((item) => countAtTimeFromMap(map: item)).toList();
}

List<MyNotification> myNotificationList(dynamic input) {
  return (input as List).map((item) => myNotificationFromMap(map: item)).toList();
}

bool isToday(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today==DateTime(dt.year, dt.month, dt.day);
}

void dismissKeyboard(context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

DateTime newTrendingCreatedAt(DateTime currTrendingCreatedAt, double trendingBoost) {
  return currTrendingCreatedAt.add(((DateTime.now().add(Duration(days: 1))).difference(currTrendingCreatedAt))*trendingBoost);
}

DateTime undoNewTrendingCreatedAt(DateTime currTrendingCreatedAt, double trendingBoost) {
  final double trendingBoostFactor = trendingBoost / (1 - trendingBoost);
  return currTrendingCreatedAt.subtract(((DateTime.now().add(Duration(days: 1))).difference(currTrendingCreatedAt))*trendingBoostFactor);
}


Future<Tuple2<T1, T2>> waitConcurrently<T1, T2>(
    Future<T1> future1, Future<T2> future2) async {
  late T1 result1;
  late T2 result2;

  await Future.wait([
    future1.then((value) => result1 = value),
    future2.then((value) => result2 = value)
  ]);

  return Future.value(Tuple2(result1, result2));
}

Future<void> openLink(LinkableElement link) async {
  if (await canLaunch(link.url)) {
    await launch(link.url);
  } else {
    throw 'Could not launch $link';
  }
}

String? httpsLink(String? link) {
  if (link!=null) {
    if (link.startsWith(RegExp("http|https|ftp"))) {
      return link;
    } else {
      return "https://" + link;
    }
  } else {
    return null;
  }
}

void cleanNotifications(DocumentReference userRef) async {
  final user = await userDataFromSnapshot(await userRef.get(), userRef);
  List<MyNotification> allNotifications = user.myNotifications;
  allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final notificationsLength = allNotifications.length;
  List<Map> temp = [];
  for (int i=maxNumNotifications; i<notificationsLength; i++) {
    temp.add(allNotifications[i].asMap());
  }
  print(temp);
  await userRef.update({C.myNotifications: FieldValue.arrayRemove(temp)});
}