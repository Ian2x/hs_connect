import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/report.dart';

class Post {
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final DocumentReference userRef;
  final String title;
  final String text;
  final String? media;
  final Timestamp createdAt;
  final int numComments;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;
  final Report? reportedStatus;
  final List<String> tags;

  Post({
    required this.postRef,
    required this.groupRef,
    required this.userRef,
    required this.title,
    required this.text,
    required this.media,
    required this.createdAt,
    required this.numComments,
    required this.likes,
    required this.dislikes,
    required this.reportedStatus,
    required this.tags,
  });
}
