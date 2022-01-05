import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'accessRestriction.dart';

class Comment {
  late DocumentReference commentRef;
  late DocumentReference postRef;
  late DocumentReference groupRef;
  late DocumentReference creatorRef;
  late String text;
  String? media;
  late Timestamp createdAt;
  late int numReplies;
  late AccessRestriction accessRestriction;
  late List<DocumentReference> likes;
  late List<DocumentReference> dislikes;
  late List<DocumentReference> reportsRefs;

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
  });

  Comment.fromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    final accessRestriction = querySnapshot.get(C.accessRestriction);
    this.commentRef = querySnapshot.reference;
    this.postRef = querySnapshot[C.postRef];
    this.groupRef = querySnapshot[C.groupRef];
    this.creatorRef = querySnapshot[C.creatorRef];
    this.text = querySnapshot[C.text];
    this.media = querySnapshot[C.media];
    this.createdAt = querySnapshot[C.createdAt];
    this.numReplies = querySnapshot[C.numReplies];
    this.accessRestriction = accessRestrictionFromMap(map: accessRestriction);
    this.likes = docRefList(querySnapshot[C.likes]);
    this.dislikes = docRefList(querySnapshot[C.dislikes]);
    this.reportsRefs = docRefList(querySnapshot[C.reportsRefs]);
  }

  Comment.fromSnapshot(DocumentSnapshot snapshot) {
    final accessRestriction = snapshot.get(C.accessRestriction);
    this.commentRef = snapshot.reference;
    this.postRef = snapshot[C.postRef];
    this.groupRef = snapshot[C.groupRef];
    this.creatorRef = snapshot[C.creatorRef];
    this.text = snapshot[C.text];
    this.media = snapshot[C.media];
    this.createdAt = snapshot[C.createdAt];
    this.numReplies = snapshot[C.numReplies];
    this.accessRestriction = accessRestrictionFromMap(map: accessRestriction);
    this.likes = docRefList(snapshot[C.likes]);
    this.dislikes = docRefList(snapshot[C.dislikes]);
    this.reportsRefs = docRefList(snapshot[C.reportsRefs]);
  }
}
