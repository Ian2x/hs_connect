import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/message.dart';

class UserGroup {
  // userGroup = name of group
  final DocumentReference groupRef;
  bool public;

  UserGroup({required this.groupRef, required this.public});

  Map<String, dynamic> asMap() {
    return {
      'groupRef': groupRef,
      'public': public,
    };
  }
}

class UserData {
  final DocumentReference userRef;
  final String displayedName;
  final String LCdisplayedName;
  final String domain;
  final String? county;
  final String? state;
  final String? country;
  final List<UserGroup> userGroups;
  final List<Message> messages;
  final String? image;
  final int score;
  final int warnings;

  UserData({
    required this.userRef,
    required this.displayedName,
    required this.LCdisplayedName,
    required this.domain,
    required this.county,
    required this.state,
    required this.country,
    required this.userGroups,
    required this.messages,
    required this.image,
    required this.score,
    required this.warnings,
  });
}
