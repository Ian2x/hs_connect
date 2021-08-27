class AccessRestrictions {
  final String? domain;
  final String? county;
  final String? state;
  final String? country;

  AccessRestrictions({
    required this.domain,
    required this.county,
    required this.state,
    required this.country,
  });

  Map<String, String?> asMap() {
    return {
      'domain': domain,
      'county': county,
      'state': state,
      'country': country,
    };
  }
}

class Group {
  final String groupId;
  final String userId;
  String name;
  String? image;
  final AccessRestrictions accessRestrictions;

  Group({
    required this.groupId,
    required this.userId,
    required this.name,
    required this.image,
    required this.accessRestrictions,
  });
}
