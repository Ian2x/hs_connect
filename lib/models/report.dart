import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final DocumentReference reporterRef;
  final String text;


  Report({
    required this.reporterRef,
    required this.text,
  });
}
