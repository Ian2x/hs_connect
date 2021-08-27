class UserGroup {
  // userGroup = name of group
  final String groupId;
  bool public;

  UserGroup({required this.groupId, required this.public});

  Map<String, dynamic> asMap() {
    return {
      'groupId': groupId,
      'public': public,
    };
  }
}
/*
List<Group> convertToGroupList(List<dynamic> list) {
  return list.map((el) => {group: el.group, public: el.public}).toList();
}
 */

class UserData {
  final String userId;
  String displayedName;
  final String domain;
  final String? county;
  final String? state;
  final String? country;
  List<UserGroup> userGroups;
  String imageURL;
  int score;

  UserData(
      {required this.userId,
      required this.displayedName,
      required this.domain,
      this.county = '',
      this.state = '',
      this.country = '',
      this.userGroups = const [],
      this.imageURL = '',
      this.score = 0});
}
