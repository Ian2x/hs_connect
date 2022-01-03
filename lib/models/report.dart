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
  late ReportType reportType;
  late DocumentReference entityRef; // ref to message, post, comment, or reply
  late DocumentReference reporterRef; // person filing the report
  late String text;
  late Timestamp createdAt;

  Report({
    required this.reportType,
    required this.entityRef,
    required this.reporterRef,
    required this.text,
    required this.createdAt,
  });

  Report.fromSnapshot(DocumentSnapshot snapshot) {
    this.reportType = reportTypeFrom(snapshot.get(C.reportType));
    this.entityRef = snapshot.get(C.entityRef);
    this.reporterRef = snapshot.get(C.reporterRef);
    this.text = snapshot.get(C.text);
    this.createdAt = snapshot.get(C.createdAt);
  }
}
