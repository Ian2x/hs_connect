import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/shared/constants.dart';

class MessagesDatabaseService {
  final DocumentReference currUserRef;

  MessagesDatabaseService({required this.currUserRef});

  // collection reference
  final CollectionReference reportsCollection = FirebaseFirestore.instance.collection(C.reports);

  Future<DocumentReference> newReport({
    required ReportType reportType,
    required DocumentReference entityRef,
    required DocumentReference reporterRef,
    required String text,
  }) async {
    return await reportsCollection.add({
      C.reportType: reportType,
      C.entityRef: entityRef,
      C.reporterRef: reporterRef,
      C.text: text,
      C.createdAt: DateTime.now(),
    });
  }

  // home data from snapshot
  Report? _reportFromSnapshot({required DocumentSnapshot snapshot}) {
    if (snapshot.exists) {
      return Report(
        entityRef: snapshot.get(C.entityRef),
        reporterRef: snapshot.get(C.reporterRef),
        text: snapshot.get(C.text),
        createdAt: snapshot.get(C.createdAt),
        reportType: reportTypeFrom(snapshot.get(C.reportType)),
      );
    } else {
      return null;
    }
  }

  Future<Report?> getGroupData({required DocumentReference reportRef}) async {
    final snapshot = await reportRef.get();
    return _reportFromSnapshot(snapshot: snapshot);
  }
}
