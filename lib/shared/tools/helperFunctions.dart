import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/myNotification.dart';

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

extension IanTime on DateTime {
  int ianTime() {
    return this.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 3);
  }
}