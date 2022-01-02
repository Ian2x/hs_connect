import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/message.dart';

class UserGroup {
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
  final String? bio;
  final String domain;
  final String? county;
  final String? state;
  final String? country;
  final List<UserGroup> userGroups;
  final List<DocumentReference> messageRefs;
  final List<DocumentReference> postsRefs;
  final List<DocumentReference> commentsRefs;
  final String? profileImage;
  final int score;
  final List<DocumentReference> reportsRefs;

  UserData({
    required this.userRef,
    required this.displayedName,
    required this.LCdisplayedName,
    required this.bio,
    required this.domain,
    required this.county,
    required this.state,
    required this.country,
    required this.userGroups,
    required this.messageRefs,
    required this.postsRefs,
    required this.commentsRefs,
    required this.profileImage,
    required this.score,
    required this.reportsRefs,
  });
}
