import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'accessRestriction.dart';

class Comment {
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final DocumentReference creatorRef;
  final String text;
  final String? media;
  final Timestamp createdAt;
  final int numReplies;
  final AccessRestriction accessRestriction;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;
  final List<DocumentReference> reportsRefs;
  final Timestamp lastUpdated;

  Comment({
    required this.commentRef,
    required this.postRef,
    required this.groupRef,
    required this.creatorRef,
    required this.text,
    required this.media,
    required this.createdAt,
    required this.numReplies,
    required this.accessRestriction,
    required this.likes,
    required this.dislikes,
    required this.reportsRefs,
    required this.lastUpdated,
  });
}

commentFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
  final accessRestriction = querySnapshot.get(C.accessRestriction);
  final temp = Comment(
      commentRef: querySnapshot.reference,
      postRef: querySnapshot[C.postRef],
      groupRef: querySnapshot[C.groupRef],
      creatorRef: querySnapshot[C.creatorRef],
      text: querySnapshot[C.text],
      media: querySnapshot[C.media],
      createdAt: querySnapshot[C.createdAt],
      numReplies: querySnapshot[C.numReplies],
      accessRestriction: accessRestrictionFromMap(accessRestriction),
      likes: docRefList(querySnapshot[C.likes]),
      dislikes: docRefList(querySnapshot[C.dislikes]),
      reportsRefs: docRefList(querySnapshot[C.reportsRefs]),
      lastUpdated: querySnapshot[C.lastUpdated]
  );
  return temp;
}

commentFromSnapshot(DocumentSnapshot snapshot) {
  final accessRestriction = snapshot.get(C.accessRestriction);
  final temp = Comment(
      commentRef: snapshot.reference,
      postRef: snapshot[C.postRef],
      groupRef: snapshot[C.groupRef],
      creatorRef: snapshot[C.creatorRef],
      text: snapshot[C.text],
      media: snapshot[C.media],
      createdAt: snapshot[C.createdAt],
      numReplies: snapshot[C.numReplies],
      accessRestriction: accessRestrictionFromMap(accessRestriction),
      likes: docRefList(snapshot[C.likes]),
      dislikes: docRefList(snapshot[C.dislikes]),
      reportsRefs: docRefList(snapshot[C.reportsRefs]),
      lastUpdated: snapshot[C.lastUpdated],
  );
  return temp;
}