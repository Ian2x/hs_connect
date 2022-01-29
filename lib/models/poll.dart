import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

class Poll {
  final DocumentReference pollRef;
  final List<String> choices; // [a,b,c,d]
  final Map<int, List<DocumentReference>> votes; // {0: [userRef1, userRef2], 1: [], 2: [userRef3, userRef4, userRef5], 3: [userRef6]}

  Poll({
    required this.pollRef,
    required this.choices,
    required this.votes,
  });
}

Poll pollFromSnapshot(DocumentSnapshot snapshot) {
  final choices = stringList(snapshot.get(C.choices));
  var votes = Map<int, List<DocumentReference>>();
  for (int i = 0; i < choices.length; i++) {
    votes[i] = docRefList(snapshot.get(i.toString()));
  }
  return Poll(
    pollRef: snapshot.reference,
    choices: choices,
    votes: votes,
  );
}
