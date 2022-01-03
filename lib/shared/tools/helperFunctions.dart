import 'package:cloud_firestore/cloud_firestore.dart';

List<DocumentReference> docRefList(dynamic input) {
  return (input as List).map((item) => item as DocumentReference).toList();
}

List<String> stringList(dynamic input) {
  return (input as List).map((item) => item as String).toList();
}
