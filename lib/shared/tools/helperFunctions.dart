import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:flutter/material.dart';

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

Color translucentColorFromString(String s) {
  Color original = Color(s.hashCode);
  return Color(s.hashCode).withOpacity(0.4);//.withRed(original.red~/2).withGreen(original.green~/2);
}

bool isToday(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today==DateTime(dt.year, dt.month, dt.day);
}