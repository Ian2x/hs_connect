import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/report.dart';

class Comment {
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference? userRef;
  final String text;
  final String? media;
  final Timestamp createdAt;
  final int numReplies;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;
  final List<DocumentReference> reports;

  Comment({
    required this.commentRef,
    required this.postRef,
    required this.userRef,
    required this.text,
    required this.media,
    required this.createdAt,
    required this.numReplies,
    required this.likes,
    required this.dislikes,
    required this.reports,
  });
}