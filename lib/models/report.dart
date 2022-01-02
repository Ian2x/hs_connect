import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType {
  message,
  post,
  comment,
  reply
}

class Report {
  final ReportType reportType;
  final DocumentReference entityRef; // ref to message, post, comment, or reply
  final DocumentReference reporterRef; // person filing the report
  final String text;
  final Timestamp createdAt;


  Report({
    required this.reportType,
    required this.entityRef,
    required this.reporterRef,
    required this.text,
    required this.createdAt,
  });
}
