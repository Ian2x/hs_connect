import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference userRef;
  String text;
  String? media;
  final String createdAt;
  int numReplies;
  List<String> likes;
  List<String> dislikes;

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
  });
}