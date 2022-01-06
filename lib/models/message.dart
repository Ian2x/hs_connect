import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

class Message {
  final DocumentReference messageRef;
  final DocumentReference senderRef;
  final DocumentReference receiverRef;
  final String text;
  final bool isMedia;
  final Timestamp createdAt;
  final List<DocumentReference> reportsRef;

  Message({
    required this.messageRef,
    required this.senderRef,
    required this.receiverRef,
    required this.text,
    required this.isMedia,
    required this.createdAt,
    required this.reportsRef,
  });
}

messageFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
  return Message(
    messageRef: querySnapshot.reference,
    senderRef: querySnapshot[C.senderRef],
    receiverRef: querySnapshot[C.receiverRef],
    text: querySnapshot[C.text],
    isMedia: querySnapshot[C.isMedia],
    createdAt: querySnapshot[C.createdAt],
    reportsRef: docRefList(querySnapshot[C.reportsRefs]),
  );
}
