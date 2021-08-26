class Group {
  final String group;
  bool public;

  Group({required this.group, required this.public});
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
  List<dynamic> groups;
  String imageURL;
  int score;

  UserData(
      {required this.userId,
      required this.displayedName,
      required this.domain,
      this.county = '',
      this.state = '',
      this.country = '',
      this.groups = const [],
      this.imageURL = '',
      this.score = 0});
}
