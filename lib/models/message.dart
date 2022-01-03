import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

class Message {
  late DocumentReference messageRef;
  late DocumentReference senderRef;
  late DocumentReference receiverRef;
  late String text;
  late bool isMedia;
  late Timestamp createdAt;
  late List<DocumentReference> reportsRef;

  Message({
    required this.messageRef,
    required this.senderRef,
    required this.receiverRef,
    required this.text,
    required this.isMedia,
    required this.createdAt,
    required this.reportsRef,
  });

  Message.fromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    this.messageRef = querySnapshot.reference;
    this.senderRef = querySnapshot[C.senderRef];
    this.receiverRef = querySnapshot[C.receiverRef];
    this.text = querySnapshot[C.text];
    this.isMedia = querySnapshot[C.isMedia];
    this.createdAt = querySnapshot[C.createdAt];
    this.reportsRef = docRefList(querySnapshot[C.reportsRefs]);
  }
}
