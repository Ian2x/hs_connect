import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/shared/constants.dart';
import 'accessRestriction.dart';
import 'group.dart';

class Post {
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final DocumentReference userRef;
  final String title;
  final String LCtitle;
  final String text;
  final String? media;
  final Timestamp createdAt;
  final int numComments;
  final AccessRestriction accessRestrictions;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;
  final List<DocumentReference> reportsRefs;
  final Tag tag;

  Post({
    required this.postRef,
    required this.groupRef,
    required this.userRef,
    required this.LCtitle,
    required this.title,
    required this.text,
    required this.media,
    required this.createdAt,
    required this.numComments,
    required this.accessRestrictions,
    required this.likes,
    required this.dislikes,
    required this.reportsRefs,
    required this.tag,
  });
}
