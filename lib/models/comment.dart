import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/report.dart';

import 'accessRestriction.dart';

class Comment {
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final DocumentReference userRef;
  final String text;
  final String? media;
  final Timestamp createdAt;
  final int numReplies;
  final AccessRestriction accessRestrictions;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;
  final List<DocumentReference> reportsRefs;

  Comment({
    required this.commentRef,
    required this.postRef,
    required this.groupRef,
    required this.userRef,
    required this.text,
    required this.media,
    required this.createdAt,
    required this.numReplies,
    required this.accessRestrictions,
    required this.likes,
    required this.dislikes,
    required this.reportsRefs,
  });
}