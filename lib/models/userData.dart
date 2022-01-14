import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/observedRef.dart';
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

class UserMessage {
  final DocumentReference otherUserRef;
  final Timestamp lastMessage;

  UserMessage({required this.otherUserRef, required this.lastMessage});

  Map<String, dynamic> asMap() {
    return {
      C.otherUserRef: otherUserRef,
      C.lastMessage: lastMessage,
    };
  }
}

UserMessage userMessageFromMap({required Map map}) {
  return UserMessage(otherUserRef: map[C.otherUserRef], lastMessage: map[C.lastMessage]);
}

class UserData {
  final DocumentReference userRef;
  final String displayedName;
  final String displayedNameLC;
  final String? bio;
  final String domain;
  final String? county;
  final String? state;
  final String? country;
  final List<UserGroup> userGroups;
  final List<DocumentReference> modGroupsRefs;
  final List<UserMessage> userMessages;
  final List<ObservedRef> myPostsObservedRefs;
  final List<DocumentReference> savedPostsRefs;
  final List<ObservedRef> myCommentsObservedRefs;
  final int numReplies;
  final String? profileImage;
  final int score;
  final int numReports;

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
    required this.userMessages,
    required this.myPostsObservedRefs,
    required this.savedPostsRefs,
    required this.myCommentsObservedRefs,
    required this.numReplies,
    required this.profileImage,
    required this.score,
    required this.numReports,
  });
}

userDataFromSnapshot(DocumentSnapshot snapshot, DocumentReference userRef) {
  return UserData(
    userRef: userRef,
    displayedName: snapshot.get(C.displayedName),
    displayedNameLC: snapshot.get(C.displayedNameLC),
    bio: snapshot.get(C.bio),
    domain: snapshot.get(C.domain),
    county: snapshot.get(C.county),
    state: snapshot.get(C.state),
    country: snapshot.get(C.country),
    userGroups: snapshot.get(C.userGroups).map<UserGroup>((userGroup) => userGroupFromMap(map: userGroup)).toList(),
    modGroupsRefs: docRefList(snapshot.get(C.modGroupRefs)),
    userMessages: snapshot.get(C.userMessages).map<UserMessage>((userMessage) => userMessageFromMap(map: userMessage)).toList(),
    myPostsObservedRefs: observedRefList(snapshot.get(C.myPostsObservedRefs)),
    savedPostsRefs: docRefList(snapshot.get(C.savedPostsRefs)),
    myCommentsObservedRefs: observedRefList(snapshot.get(C.myCommentsObservedRefs)),
    numReplies: snapshot.get(C.numReplies),
    profileImage: snapshot.get(C.profileImage),
    score: snapshot.get(C.score),
    numReports: snapshot.get(C.numReports),
  );
}