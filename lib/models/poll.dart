import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  final DocumentReference pollRef;
  final DocumentReference postRef;
  final String prompt;
  final List<String> choices; // [a,b,c,d]
  final Map votes; // {0: [userRef1, userRef2], 1: [], 2: [userRef3, userRef4, userRef5], 3: [userRef6]}
  final Timestamp createdAt;

  Poll({
    required this.pollRef,
    required this.postRef,
    required this.prompt,
    required this.choices,
    required this.votes,
    required this.createdAt,
  });
}
