import 'package:cloud_firestore/cloud_firestore.dart';

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
  String displayedName;
  final String domain;
  String? county;
  String? state;
  String? country;
  List<UserGroup> userGroups;
  String? image;
  int score;

  UserData(
      {required this.userRef,
      required this.displayedName,
      required this.domain,
      this.county = '<county>',
      this.state = '<state>',
      this.country = '<country>',
      this.userGroups = const [],
      this.image = null,
      this.score = 0});
}
