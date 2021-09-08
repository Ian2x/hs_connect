import 'dart:collection';

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

  // CURRENTLY NOT WORKING
  static AccessRestriction hashmapToAR({required HashMap hashMap}) {
    return AccessRestriction(restriction: hashMap['restriction'], restrictionType: hashMap['restrictionType']);
  }
}

class Group {
  final String groupId;
  final String userId;
  String name;
  String? image;
  final AccessRestriction accessRestrictions;

  Group({
    required this.groupId,
    required this.userId,
    required this.name,
    required this.image,
    required this.accessRestrictions,
  });
}