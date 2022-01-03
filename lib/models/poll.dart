import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

class Poll {
  late DocumentReference pollRef;
  late DocumentReference postRef;
  late DocumentReference groupRef;
  late DocumentReference creatorRef;
  late AccessRestriction accessRestriction;
  late String prompt;
  late List<String> choices; // [a,b,c,d]
  late Map votes; // {0: [userRef1, userRef2], 1: [], 2: [userRef3, userRef4, userRef5], 3: [userRef6]}
  late Timestamp createdAt;

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

  Poll.fromSnapshot(DocumentSnapshot snapshot) {
    final choices = stringList(snapshot.get(C.choices));
    var votes = Map();
    for (int i = 0; i < choices.length; i++) {
      votes[i] = docRefList(snapshot.get(i.toString()));
    }
    this.pollRef = snapshot.get(C.pollRef);
    this.postRef = snapshot.get(C.postRef);
    this.groupRef = snapshot.get(C.groupRef);
    this.prompt = snapshot.get(C.prompt);
    this.choices = choices;
    this.votes = votes;
    this.createdAt = snapshot.get(C.createdAt);
  }
}
