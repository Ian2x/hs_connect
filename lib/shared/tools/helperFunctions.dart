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