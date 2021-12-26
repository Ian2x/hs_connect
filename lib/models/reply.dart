import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final DocumentReference replyRef;
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference userRef;
  String text;
  String? media;
  final String createdAt;
  List<DocumentReference> likes;
  List<DocumentReference> dislikes;

  Reply({
    required this.replyRef,
    required this.commentRef,
    required this.postRef,
    required this.userRef,
    required this.text,
    required this.media,
    required this.createdAt,
    required this.likes,
    required this.dislikes,
  });
}