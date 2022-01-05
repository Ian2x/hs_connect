import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';

enum ReportType { message, post, comment, reply }

extension ReportTypeExtension on ReportType {
  String get string {
    switch (this) {
      case ReportType.message:
        return C.message;
      case ReportType.post:
        return C.post;
      case ReportType.comment:
        return C.comment;
      case ReportType.reply:
        return C.reply;
    }
  }
}

ReportType reportTypeFrom(String reportType) {
  switch (reportType) {
    case C.message:
      return ReportType.message;
    case C.post:
      return ReportType.post;
    case C.comment:
      return ReportType.comment;
    case C.reply:
      return ReportType.reply;
    default:
      throw FormatException(reportType + "is not a ReportType type");
  }
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

reportFromSnapshot(DocumentSnapshot snapshot) {
  return Report(
    reportType: reportTypeFrom(snapshot.get(C.reportType)),
    entityRef: snapshot.get(C.entityRef),
    reporterRef: snapshot.get(C.reporterRef),
    text: snapshot.get(C.text),
    createdAt: snapshot.get(C.createdAt),
  );
}