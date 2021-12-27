import 'package:cloud_firestore/cloud_firestore.dart';

class AccessRestriction {
  final String restrictionType; // domain, county, state, or country
  final String restriction;

  AccessRestriction({
    required this.restrictionType,
    required this.restriction,
  });

  @override
  bool operator ==(Object other) => other is AccessRestriction && other.restriction == restriction && other.restrictionType == restrictionType;

  Map<String, String?> asMap() {
    return {
      'restrictionType': restrictionType,
      'restriction': restriction,
    };
  }

  // CURRENTLY NOT WORKING? SEE GROUPS_DATABASE
  static AccessRestriction mapToAR({required Map map}) {
    return AccessRestriction(restriction: map['restriction'], restrictionType: map['restrictionType']);
  }
}

class Group {
  final DocumentReference groupRef;
  final DocumentReference? creatorRef;
  final List<DocumentReference> moderatorRefs;
  final String name;
  final String? image;
  final String? description;
  final AccessRestriction accessRestrictions;
  final Timestamp createdAt;
  final int numPosts;

  Group({
    required this.groupRef,
    required this.creatorRef,
    required this.moderatorRefs,
    required this.name,
    required this.image,
    required this.description,
    required this.accessRestrictions,
    required this.createdAt,
    required this.numPosts,
  });
}
