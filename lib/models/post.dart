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
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final DocumentReference creatorRef;
  final String title;
  final String titleLC;
  final String? text;
  final String? media;
  final Timestamp createdAt;
  final List<DocumentReference> commentsRefs;
  final List<DocumentReference> repliesRefs;
  final AccessRestriction accessRestriction;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;
  final List<DocumentReference> reportsRefs;
  final DocumentReference? pollRef;
  final Tag? tag;

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
}

postFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
  final accessRestriction = querySnapshot[C.accessRestriction];
  return Post(
    postRef: querySnapshot.reference,
    groupRef: querySnapshot[C.groupRef],
    creatorRef: querySnapshot[C.creatorRef],
    title: querySnapshot[C.title],
    titleLC: querySnapshot[C.titleLC],
    text: querySnapshot[C.text],
    media: querySnapshot[C.media],
    createdAt: querySnapshot[C.createdAt],
    commentsRefs: docRefList(querySnapshot[C.commentsRefs]),
    repliesRefs: docRefList(querySnapshot[C.repliesRefs]),
    accessRestriction: accessRestrictionFromMap(accessRestriction),
    likes: docRefList(querySnapshot[C.likes]),
    dislikes: docRefList(querySnapshot[C.dislikes]),
    reportsRefs: docRefList(querySnapshot[C.reportsRefs]),
    pollRef: querySnapshot[C.pollRef],
    tag: tagFrom(querySnapshot[C.tag]),
  );
}

postFromSnapshot(DocumentSnapshot snapshot) {
  final accessRestriction = snapshot[C.accessRestriction];
  return Post(
    postRef: snapshot.reference,
    groupRef: snapshot[C.groupRef],
    creatorRef: snapshot[C.creatorRef],
    title: snapshot[C.title],
    titleLC: snapshot[C.titleLC],
    text: snapshot[C.text],
    media: snapshot[C.media],
    createdAt: snapshot[C.createdAt],
    commentsRefs: docRefList(snapshot[C.commentsRefs]),
    repliesRefs: docRefList(snapshot[C.repliesRefs]),
    accessRestriction: accessRestrictionFromMap(accessRestriction),
    likes: docRefList(snapshot[C.likes]),
    dislikes: docRefList(snapshot[C.dislikes]),
    reportsRefs: docRefList(snapshot[C.reportsRefs]),
    pollRef: snapshot[C.pollRef],
    tag: tagFrom(snapshot[C.tag]),
  );
}