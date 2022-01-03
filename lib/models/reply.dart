import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

class Reply {
  late DocumentReference replyRef;
  late DocumentReference creatorRef;
  late DocumentReference commentRef;
  late DocumentReference postRef;
  late DocumentReference groupRef;
  late AccessRestriction accessRestriction;
  late String text;
  String? media;
  late Timestamp createdAt;
  late List<DocumentReference> likes;
  late List<DocumentReference> dislikes;
  late List<DocumentReference> reportsRefs;

  Reply({
    required this.replyRef,
    required this.creatorRef,
    required this.commentRef,
    required this.postRef,
    required this.groupRef,
    required this.accessRestriction,
    required this.text,
    required this.media,
    required this.createdAt,
    required this.likes,
    required this.dislikes,
    required this.reportsRefs,
  });

  Reply.fromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    final accessRestriction = querySnapshot.get(C.accessRestriction);
    this.replyRef = querySnapshot.reference;
    this.creatorRef = querySnapshot[C.creatorRef];
    this.commentRef = querySnapshot[C.commentRef];
    this.postRef = querySnapshot[C.postRef];
    this.groupRef = querySnapshot[C.groupRef];
    this.accessRestriction = accessRestrictionFromMap(map: accessRestriction);
    this.text = querySnapshot[C.text];
    this.media = querySnapshot[C.media];
    this.createdAt = querySnapshot[C.createdAt];
    this.likes = docRefList(querySnapshot[C.likes]);
    this.dislikes = docRefList(querySnapshot[C.dislikes]);
    this.reportsRefs = docRefList(querySnapshot[C.reportsRefs]);
  }
}
