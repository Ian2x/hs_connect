import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

class Poll {
  final DocumentReference pollRef;
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final DocumentReference creatorRef;
  final AccessRestriction accessRestriction;
  final String prompt;
  final List<String> choices; // [a,b,c,d]
  final Map votes; // {0: [userRef1, userRef2], 1: [], 2: [userRef3, userRef4, userRef5], 3: [userRef6]}
  final Timestamp createdAt;

  Poll({
    required this.pollRef,
    required this.postRef,
    required this.groupRef,
    required this.creatorRef,
    required this.accessRestriction,
    required this.prompt,
    required this.choices,
    required this.votes,
    required this.createdAt,
  });
}

pollFromSnapshot(DocumentSnapshot snapshot) {
  final choices = stringList(snapshot.get(C.choices));
  var votes = Map();
  for (int i = 0; i < choices.length; i++) {
  votes[i] = docRefList(snapshot.get(i.toString()));
  }
  final accessRestriction = snapshot[C.accessRestriction];
  return Poll(
    pollRef: snapshot[C.pollRef],
    postRef: snapshot[C.postRef],
    groupRef: snapshot[C.groupRef],
    creatorRef: snapshot[C.creatorRef],
    accessRestriction: accessRestrictionFromMap(accessRestriction),
    prompt: snapshot[C.prompt],
    choices: choices,
    votes: votes,
    createdAt: snapshot[C.createdAt],
  );
}
