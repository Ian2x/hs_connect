import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/shared/constants.dart';

class ReportsDatabaseService {
  final DocumentReference currUserRef;

  ReportsDatabaseService({required this.currUserRef});

  // collection reference
  final CollectionReference reportsCollection = FirebaseFirestore.instance.collection(C.reports);

  Future<DocumentReference> newReport({
    required ReportType reportType,
    required DocumentReference entityRef,
    required DocumentReference reporterRef,
    required String text,
  }) async {
    entityRef.update({C.numReports: FieldValue.increment(1)});
    return await reportsCollection.add({
      C.reportType: reportType.string,
      C.entityRef: entityRef,
      C.reporterRef: reporterRef,
      C.text: text,
      C.createdAt: DateTime.now(),
    });
  }

  // home data from snapshot
  Report? _reportFromSnapshot({required DocumentSnapshot snapshot}) {
    if (snapshot.exists) {
      return reportFromSnapshot(snapshot);
    } else {
      return null;
    }
  }

  Future<Report?> getReportData({required DocumentReference reportRef}) async {
    final snapshot = await reportRef.get();
    return _reportFromSnapshot(snapshot: snapshot);
  }
}
