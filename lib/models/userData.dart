import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

class UserGroup {
  final DocumentReference groupRef;
  bool public;

  UserGroup({required this.groupRef, required this.public});

  Map<String, dynamic> asMap() {
    return {
      C.groupRef: groupRef,
      C.public: public,
    };
  }
}

UserGroup userGroupFromMap({required Map map}) {
  return UserGroup(groupRef: map[C.groupRef], public: map[C.public]);
}

class UserData {
  late DocumentReference userRef;
  late String displayedName;
  late String displayedNameLC;
  String? bio;
  late String domain;
  String? county;
  String? state;
  String? country;
  late List<UserGroup> userGroups;
  late List<DocumentReference> modGroupsRefs;
  late List<DocumentReference> messagesRefs;
  late List<DocumentReference> myPostsRefs;
  late List<DocumentReference> savedPostsRefs;
  late List<DocumentReference> myCommentsRefs;
  late List<DocumentReference> myRepliesRefs;
  String? profileImage;
  late int score;
  late List<DocumentReference> reportsRefs;

  UserData({
    required this.userRef,
    required this.displayedName,
    required this.displayedNameLC,
    required this.bio,
    required this.domain,
    required this.county,
    required this.state,
    required this.country,
    required this.userGroups,
    required this.modGroupsRefs,
    required this.messagesRefs,
    required this.myPostsRefs,
    required this.savedPostsRefs,
    required this.myCommentsRefs,
    required this.myRepliesRefs,
    required this.profileImage,
    required this.score,
    required this.reportsRefs,
  });

  UserData.fromSnapshot(DocumentSnapshot snapshot, DocumentReference userRef) {
    this.userRef = userRef;
    this.displayedName = snapshot.get(C.displayedName);
    this.displayedNameLC = snapshot.get(C.displayedNameLC);
    this.bio = snapshot.get(C.bio);
    this.domain = snapshot.get(C.domain);
    this.county = snapshot.get(C.county);
    this.state = snapshot.get(C.state);
    this.country = snapshot.get(C.country);
    this.userGroups =
        snapshot.get(C.userGroups).map<UserGroup>((userGroup) => userGroupFromMap(map: userGroup)).toList();
    this.modGroupsRefs = docRefList(snapshot.get(C.modGroupRefs));
    this.messagesRefs = docRefList(snapshot.get(C.messagesRefs));
    this.myPostsRefs = docRefList(snapshot.get(C.myPostsRefs));
    this.savedPostsRefs = docRefList(snapshot.get(C.savedPostsRefs));
    this.myCommentsRefs = docRefList(snapshot.get(C.myCommentsRefs));
    this.myRepliesRefs = docRefList(snapshot.get(C.myRepliesRefs));
    this.profileImage = snapshot.get(C.profileImage);
    this.score = snapshot.get(C.score);
    this.reportsRefs = docRefList(snapshot.get(C.reportsRefs));
  }
}
