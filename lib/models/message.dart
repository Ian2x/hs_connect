import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/report.dart';

class Message {
  final DocumentReference messageRef;
  final DocumentReference senderRef;
  final DocumentReference receiverRef;
  final String text;
  final bool isMedia;
  final Timestamp createdAt;
  final DocumentReference? reportedStatus;



  Message({
    required this.messageRef,
    required this.senderRef,
    required this.receiverRef,
    required this.text,
    required this.isMedia,
    required this.createdAt,
    required this.reportedStatus,
  });
}
