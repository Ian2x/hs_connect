import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final DocumentReference entityRef;
  final DocumentReference reporterRef;
  final String text;


  Report({
    required this.entityRef,
    required this.reporterRef,
    required this.text,
  });
}
