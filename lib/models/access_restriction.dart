enum AccessRestrictionType {
  posts,
  groups,
  people
}

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
