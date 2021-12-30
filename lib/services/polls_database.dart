import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/poll.dart';
import 'package:hs_connect/models/report.dart';

class PollsDatabaseService {
  final DocumentReference? pollRef;

  PollsDatabaseService({this.pollRef});

  // collection reference
  final CollectionReference pollsCollection = FirebaseFirestore.instance.collection('polls');

  Future<DocumentReference> newPoll({
    required DocumentReference postRef,
    required String prompt,
    required List<String> choices,
  }) async {

    final newPollRef = await pollsCollection.add({
      'postRef': postRef,
      'prompt': prompt,
      'choices': choices,
      'createdAt': DateTime.now(),
    });
    for (int i=0; i<choices.length; i++) {
      await newPollRef.update({i.toString(): []});
    }
    await postRef.update({'poll': newPollRef});
    return newPollRef;

  }

  // home data from snapshot
  Poll? _pollFromSnapshot({required DocumentSnapshot snapshot}) {
    if (snapshot.exists) {
      final choices = (snapshot.get('choices') as List).map((item) => item as String).toList();
      var votes = Map();
      for (int i=0; i<choices.length; i++) {
        votes[i] = (snapshot.get(i.toString()) as List).map((item) => item as DocumentReference).toList();
      }
      return Poll(
        pollRef: snapshot.get('pollRef'),
        postRef: snapshot.get('postRef'),
        prompt: snapshot.get('prompt'),
        choices: choices,
        votes: votes,
        createdAt: snapshot.get('createdAt'),
      );
    } else {
      return null;
    }
  }

  Future<bool> alreadyVoted({required DocumentReference pollRef, required DocumentReference userRef}) async {
    final pollData = await pollRef.get();
    final numChoices = (pollData.get('choices') as List).length;
    for (int i=0; i<numChoices; i++) {
      final List<DocumentReference> voters = (pollData.get(i.toString()) as List).map((item) => item as DocumentReference).toList();
      for (int j=0; j<voters.length; j++) {
        if (voters[j]==userRef) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> clearMyVotes({required DocumentReference pollRef, required DocumentReference userRef}) async {
    final pollData = await pollRef.get();
    final numChoices = (pollData.get('choices') as List).length;
    for (int i=0; i<numChoices; i++) {
      pollRef.update({i.toString(): FieldValue.arrayRemove([userRef])});
    }
  }

  Future<void> vote({required DocumentReference pollRef, required DocumentReference userRef, required int choice}) async {
    await pollRef.update({choice.toString(): FieldValue.arrayUnion([userRef])});
  }

  Future<Poll?> getPoll() async {
    final snapshot = await pollRef!.get();
    return _pollFromSnapshot(snapshot: snapshot);
  }
}
