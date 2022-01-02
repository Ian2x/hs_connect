import 'package:cloud_firestore/cloud_firestore.dart';
import 'access_restriction.dart';

class Group {
  final DocumentReference groupRef;
  final DocumentReference? creatorRef;
  final List<DocumentReference> moderatorRefs;
  final String name;
  final String LCname;
  final String? image;
  final String? description;
  final AccessRestriction accessRestrictions;
  final Timestamp createdAt;
  final int numPosts;
  final int numMembers;

  Group({
    required this.groupRef,
    required this.creatorRef,
    required this.moderatorRefs,
    required this.name,
    required this.LCname,
    required this.image,
    required this.description,
    required this.accessRestrictions,
    required this.createdAt,
    required this.numPosts,
    required this.numMembers,
  });
}
