import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/observedRef.dart';

List<DocumentReference> docRefList(dynamic input) {
  return (input as List).map((item) => item as DocumentReference).toList();
}

List<String> stringList(dynamic input) {
  return (input as List).map((item) => item as String).toList();
}

List<CountAtTime> countAtTimeList(dynamic input) {
  return (input as List).map((item) => countAtTimeFromMap(map: item)).toList();
}

List<ObservedRef> observedRefList(dynamic input) {
  return (input as List).map((item) => observedRefFromMap(map: item)).toList();
}

Color translucentColorFromString(String s) {
  Color original = Color(s.hashCode);
  return Color(s.hashCode).withOpacity(0.4);//.withRed(original.red~/2).withGreen(original.green~/2);
}