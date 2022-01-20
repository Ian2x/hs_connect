import 'package:hs_connect/shared/constants.dart';
import 'package:quiver/core.dart';

enum AccessRestrictionType { domain, county, state, country }

extension AccessRestrictionTypeExtension on AccessRestrictionType {
  String get string {
    switch (this) {
      case AccessRestrictionType.domain:
        return C.domain;
      case AccessRestrictionType.county:
        return C.county;
      case AccessRestrictionType.state:
        return C.state;
      case AccessRestrictionType.country:
        return C.country;
    }
  }
}

accessRestrictionTypeFrom(String accessRestrictionType) {
  switch (accessRestrictionType) {
    case C.domain:
      return AccessRestrictionType.domain;
    case C.county:
      return AccessRestrictionType.county;
    case C.state:
      return AccessRestrictionType.state;
    case C.country:
      return AccessRestrictionType.country;
  }
}

class AccessRestriction {
  final AccessRestrictionType restrictionType; // domain, county, state, or country
  final String restriction;

  AccessRestriction({
    required this.restrictionType,
    required this.restriction,
  });

  @override
  bool operator ==(Object other) =>
      other is AccessRestriction && other.restriction == restriction && other.restrictionType == restrictionType;

  @override
  int get hashCode => hash2(restrictionType.hashCode, restriction.hashCode);

  Map<String, dynamic> asMap() {
    return {
      C.restrictionType: restrictionType.string,
      C.restriction: restriction,
    };
  }
}

AccessRestriction accessRestrictionFromMap(Map map) {
  final temp = AccessRestriction(
      restriction: map[C.restriction], restrictionType: accessRestrictionTypeFrom(map[C.restrictionType]));
  return temp;
}

class Access {
  final String domain;
  final String? county;
  final String? state;
  final String? country;

  Access({
    required this.domain,
    required this.county,
    required this.state,
    required this.country,
  });

  bool haveAccess(AccessRestriction ar) {
    switch (ar.restrictionType) {
      case AccessRestrictionType.domain:
        return ar.restriction==this.domain;
      case AccessRestrictionType.county:
        return ar.restriction==this.county;
      case AccessRestrictionType.state:
        return ar.restriction==this.state;
      case AccessRestrictionType.country:
        return ar.restriction==this.country;
    }
  }
}
