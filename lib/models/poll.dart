import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';

class Poll {
  final DocumentReference pollRef;
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final DocumentReference userRef;
  final AccessRestriction accessRestriction;
  final String prompt;
  final List<String> choices; // [a,b,c,d]
  final Map votes; // {0: [userRef1, userRef2], 1: [], 2: [userRef3, userRef4, userRef5], 3: [userRef6]}
  final Timestamp createdAt;

  Poll({
    required this.pollRef,
    required this.postRef,
    required this.groupRef,
    required this.userRef,
    required this.accessRestriction,
    required this.prompt,
    required this.choices,
    required this.votes,
    required this.createdAt,
  });
}
