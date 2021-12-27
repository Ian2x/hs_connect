import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/report.dart';

class Reply {
  final DocumentReference replyRef;
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference userRef;
  final String text;
  final String? media;
  final String createdAt;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;
  final Report? reportedStatus;

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
    required this.reportedStatus,
  });
}