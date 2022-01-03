import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'accessRestriction.dart';

class Group {
  late DocumentReference groupRef;
  DocumentReference? creatorRef;
  late List<DocumentReference> moderatorRefs;
  late String name;
  late String nameLC;
  String? image;
  String? description;
  late AccessRestriction accessRestriction;
  late Timestamp createdAt;
  late int numPosts;
  late int numMembers;
  late List<DocumentReference> reportsRefs;

  Group({
    required this.groupRef,
    required this.creatorRef,
    required this.moderatorRefs,
    required this.name,
    required this.nameLC,
    required this.image,
    required this.description,
    required this.accessRestriction,
    required this.createdAt,
    required this.numPosts,
    required this.numMembers,
    required this.reportsRefs,
  });

  Group.fromSnapshot(DocumentSnapshot snapshot) {
    final accessRestriction = snapshot.get(C.accessRestriction);
    this.groupRef = snapshot.reference;
    this.creatorRef = snapshot.get(C.creatorRef);
    this.moderatorRefs = docRefList(snapshot.get(C.moderatorRefs));
    this.name = snapshot.get(C.name);
    this.nameLC = snapshot.get(C.nameLC);
    this.image = snapshot.get(C.image);
    this.description = snapshot.get(C.description);
    this.accessRestriction = accessRestrictionFromMap(map: accessRestriction);
    this.createdAt = snapshot.get(C.createdAt);
    this.numPosts = snapshot.get(C.numPosts);
    this.numMembers = snapshot.get(C.numMembers);
    this.reportsRefs = docRefList(snapshot.get(C.reportsRefs));
  }
}
