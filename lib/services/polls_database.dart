import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/poll.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

class PollsDatabaseService {
  final DocumentReference? pollRef;

  PollsDatabaseService({this.pollRef});

  // collection reference
  static final CollectionReference pollsCollection = FirebaseFirestore.instance.collection(C.polls);

  Future<DocumentReference> newPoll({
    required List<String> choices,
  }) async {
    final newPollRef = await pollsCollection.add({
      C.choices: choices,
      C.createdAt: DateTime.now(),
    });
    for (int i = 0; i < choices.length; i++) {
      await newPollRef.update({i.toString(): []});
    }
    return newPollRef;
  }

  // home data from snapshot
  Poll? _pollFromSnapshot({required DocumentSnapshot snapshot}) {
    if (snapshot.exists) {
      return pollFromSnapshot(snapshot);
    } else {
      return null;
    }
  }

  Future<bool> alreadyVoted({required DocumentReference pollRef, required DocumentReference userRef}) async {
    final pollData = await pollRef.get();
    final numChoices = (pollData.get(C.choices) as List).length;
    for (int i = 0; i < numChoices; i++) {
      final List<DocumentReference> voters =
          (pollData.get(i.toString()) as List).map((item) => item as DocumentReference).toList();
      for (int j = 0; j < voters.length; j++) {
        if (voters[j] == userRef) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> clearMyVotes({required DocumentReference pollRef, required DocumentReference userRef}) async {
    final pollData = await pollRef.get();
    final numChoices = (pollData.get(C.choices) as List).length;
    for (int i = 0; i < numChoices; i++) {
      pollRef.update({
        i.toString(): FieldValue.arrayRemove([userRef])
      });
    }
  }

  Future<void> vote(
      {required DocumentReference pollRef,
      required DocumentReference userRef,
      required int choice,
      required Post post}) async {
    // boost post trending
    post.postRef
        .update({C.trendingCreatedAt: newTrendingCreatedAt(post.trendingCreatedAt.toDate(), post.createdAt.toDate(), trendingPollVoteBoost)});
    await pollRef.update({
      choice.toString(): FieldValue.arrayUnion([userRef])
    });
  }

  Future<Poll?> getPoll() async {
    final snapshot = await pollRef!.get();
    return _pollFromSnapshot(snapshot: snapshot);
  }
}
