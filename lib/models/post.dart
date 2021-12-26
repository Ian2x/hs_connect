import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final DocumentReference userRef;
  String title;
  String text;
  String? media;
  final Timestamp createdAt;
  int numComments;
  List<DocumentReference> likes;
  List<DocumentReference> dislikes;

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
  });
}
