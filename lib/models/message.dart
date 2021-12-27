import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final DocumentReference messageRef;
  final DocumentReference sender;
  final DocumentReference receiver;
  final String text;
  final Timestamp createdAt;



  Message({
    required this.messageRef,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.createdAt,
  });
}
