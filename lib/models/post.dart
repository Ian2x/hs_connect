import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'accessRestriction.dart';

enum Tag { Relationships, Parties, Memes, Classes, Advice, College, Confession }

extension TagExtension on Tag {
  String get string {
    switch (this) {
      case Tag.Relationships:
        return C.Relationships;
      case Tag.Parties:
        return C.Parties;
      case Tag.Memes:
        return C.Memes;
      case Tag.Classes:
        return C.Classes;
      case Tag.Advice:
        return C.Advice;
      case Tag.College:
        return C.College;
      case Tag.Confession:
        return C.Confession;
    }
  }
}

Tag? tagFrom(String? tag) {
  if (tag==null || tag=='') return null;
  switch (tag) {
    case C.Relationships:
      return Tag.Relationships;
    case C.Parties:
      return Tag.Parties;
    case C.Memes:
      return Tag.Memes;
    case C.Classes:
      return Tag.Classes;
    case C.Advice:
      return Tag.Advice;
    case C.College:
      return Tag.College;
    case C.Confession:
      return Tag.Confession;
    default:
      throw FormatException(tag + "is not a Tag type");
  }
}

class Post {
  late DocumentReference postRef;
  late DocumentReference groupRef;
  late DocumentReference creatorRef;
  late String title;
  late String titleLC;
  String? text;
  String? media;
  late Timestamp createdAt;
  late List<DocumentReference> commentsRefs;
  late List<DocumentReference> repliesRefs;
  late AccessRestriction accessRestriction;
  late List<DocumentReference> likes;
  late List<DocumentReference> dislikes;
  late List<DocumentReference> reportsRefs;
  DocumentReference? pollRef;
  late Tag? tag;

  Post({
    required this.postRef,
    required this.groupRef,
    required this.creatorRef,
    required this.title,
    required this.titleLC,
    required this.text,
    required this.media,
    required this.createdAt,
    required this.commentsRefs,
    required this.repliesRefs,
    required this.accessRestriction,
    required this.likes,
    required this.dislikes,
    required this.reportsRefs,
    required this.pollRef,
    required this.tag,
  });

  Post.fromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    final accessRestriction = querySnapshot[C.accessRestriction];
    this.postRef = querySnapshot.reference;
    this.groupRef = querySnapshot[C.groupRef];
    this.creatorRef = querySnapshot[C.creatorRef];
    this.title = querySnapshot[C.title];
    this.titleLC = querySnapshot[C.titleLC];
    this.text = querySnapshot[C.text];
    this.media = querySnapshot[C.media];
    this.createdAt = querySnapshot[C.createdAt];
    this.commentsRefs = docRefList(querySnapshot[C.commentsRefs]);
    this.repliesRefs = docRefList(querySnapshot[C.repliesRefs]);
    this.accessRestriction = accessRestrictionFromMap(map: accessRestriction);
    this.likes = docRefList(querySnapshot[C.likes]);
    this.dislikes = docRefList(querySnapshot[C.dislikes]);
    this.reportsRefs = docRefList(querySnapshot[C.reportsRefs]);
    this.pollRef = querySnapshot[C.pollRef];
    this.tag = tagFrom(querySnapshot[C.tag]);
  }

  Post.fromSnapshot(DocumentSnapshot snapshot) {
    final accessRestriction = snapshot.get(C.accessRestriction);
    this.postRef = snapshot.reference;
    this.groupRef = snapshot.get(C.groupRef);
    this.creatorRef = snapshot.get(C.creatorRef);
    this.title = snapshot.get(C.title);
    this.titleLC = snapshot.get(C.titleLC);
    this.text = snapshot.get(C.text);
    this.media = snapshot.get(C.media);
    this.createdAt = snapshot.get(C.createdAt);
    this.commentsRefs = docRefList(snapshot.get(C.commentsRefs));
    this.repliesRefs = docRefList(snapshot.get(C.repliesRefs));
    this.accessRestriction = accessRestrictionFromMap(map: accessRestriction);
    this.likes = docRefList(snapshot.get(C.likes));
    this.dislikes = docRefList(snapshot.get(C.dislikes));
    this.reportsRefs = docRefList(snapshot.get(C.reportsRefs));
    this.pollRef = snapshot.get(C.pollRef);
    this.tag = tagFrom(snapshot.get(C.tag));
  }
}
