import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/shared/constants.dart';

class MyNotificationsDatabaseService {
  final DocumentReference userRef;

  MyNotificationsDatabaseService({required this.userRef});

  // collection reference
  static final CollectionReference myNotificationsCollection = FirebaseFirestore.instance.collection(C.myNotifications);

  Future<DocumentReference> newNotification({
    required DocumentReference parentPostRef,
    required MyNotificationType myNotificationType,
    required DocumentReference sourceRef,
    required DocumentReference sourceUserRef,
    required DocumentReference notifiedUserRef,
    required String? extraData
  }) async {
    final messageRef = await myNotificationsCollection.add({
      C.parentPostRef: parentPostRef,
      C.myNotificationType: myNotificationType.string,
      C.sourceRef: sourceRef,
      C.sourceUserRef: sourceUserRef,
      C.notifiedUserRef: notifiedUserRef,
      C.createdAt: Timestamp.now(),
      C.extraData: extraData,
    });
    return messageRef;
  }

  // home data from snapshot
  MyNotification? _myNotificationFromDocument(QueryDocumentSnapshot querySnapshot) {
    if (querySnapshot.exists) {
      return myNotificationFromSnapshot(querySnapshot);
    } else {
      return null;
    }
  }

  Future<List<MyNotification>> getNotifications() async {
    final querySnapshot = await myNotificationsCollection.where(C.notifiedUserRef, isEqualTo: userRef).orderBy(C.createdAt).get();
    List<MyNotification?> notificationss = querySnapshot.docs.map(_myNotificationFromDocument).toList();
    notificationss.removeWhere((value) => value == null);
    return notificationss.map((item) => item!).toList();
  }

  Stream<List<MyNotification?>> numNotificationsStream() {
    return myNotificationsCollection.where(C.notifiedUserRef, isEqualTo: userRef).orderBy(C.createdAt).snapshots().map((snapshot) => snapshot.docs.map(_myNotificationFromDocument).toList());;
  }
}
