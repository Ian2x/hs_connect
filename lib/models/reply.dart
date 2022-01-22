import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

class Reply {
  final DocumentReference replyRef;
  final DocumentReference creatorRef;
  final DocumentReference commentRef;
  final DocumentReference postRef;
  final DocumentReference groupRef;
  final AccessRestriction accessRestriction;
  final String text;
  final String? media;
  final Timestamp createdAt;
  final List<DocumentReference> likes;
  final List<DocumentReference> dislikes;
  final int numReports;

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
    required this.numReports,
  });
}

Reply replyFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
  final accessRestriction = querySnapshot.get(C.accessRestriction);
  return Reply(
    replyRef: querySnapshot.reference,
    creatorRef: querySnapshot[C.creatorRef],
    commentRef: querySnapshot[C.commentRef],
    postRef: querySnapshot[C.postRef],
    groupRef: querySnapshot[C.groupRef],
    accessRestriction: accessRestrictionFromMap(accessRestriction),
    text: querySnapshot[C.text],
    media: querySnapshot[C.mediaURL],
    createdAt: querySnapshot[C.createdAt],
    likes: docRefList(querySnapshot[C.likes]),
    dislikes: docRefList(querySnapshot[C.dislikes]),
    numReports: querySnapshot[C.numReports],
  );
}
