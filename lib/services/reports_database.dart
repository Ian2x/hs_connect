import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:async/async.dart' show StreamGroup;



class MessagesDatabaseService {
  final DocumentReference currUserRef;

  MessagesDatabaseService({required this.currUserRef});

  // collection reference
  final CollectionReference reportsCollection = FirebaseFirestore.instance.collection('reports');

  Future<DocumentReference> newReport({
    required DocumentReference entityRef,
    required DocumentReference reporterRef,
    required String text,
    required Timestamp createdAt,
  }) async {
    return await reportsCollection
        .add({
      'entityRef': entityRef,
      'reporterRef': reporterRef,
      'text': text,
      'createdAt': createdAt,
    });
  }

  // home data from snapshot
  Report? _reportFromSnapshot({required DocumentSnapshot snapshot}) {
    if (snapshot.exists) {
      return Report(
        entityRef: snapshot.get('entityRef'),
        reporterRef: snapshot.get('reporterRef'),
        text: snapshot.get('text'),
        createdAt: snapshot.get('createdAt'),
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
