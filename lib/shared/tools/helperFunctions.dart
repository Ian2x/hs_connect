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