import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/services/domains_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'domainData.dart';

class UserMessage {
  final DocumentReference otherUserRef;
  Timestamp lastMessage;
  Timestamp? lastViewed;

  UserMessage({required this.otherUserRef, required this.lastMessage, required this.lastViewed});

  Map<String, dynamic> asMap() {
    return {
      C.otherUserRef: otherUserRef,
      C.lastMessage: lastMessage,
      C.lastViewed: lastViewed,
    };
  }
}

UserMessage userMessageFromMap({required Map map}) {
  return UserMessage(otherUserRef: map[C.otherUserRef], lastMessage: map[C.lastMessage], lastViewed: map[C.lastViewed]);
}

class UserData {
  final DocumentReference userRef;
  final String displayedName;
  final String displayedNameLC;
  final String? bio;
  final String domain;
  final List<DocumentReference> groups;
  final List<DocumentReference> modGroupsRefs;
  final List<UserMessage> userMessages;
  final List<DocumentReference> savedPostsRefs;
  final List<MyNotification> myNotifications;
  final String? profileImageURL;
  final int score;
  final int numReports;
  final bool private;
  final String? profileImage;
  // extracted data
  final String? fullDomainName;
  final Color? domainColor;
  final String? currCounty;
  final String? currState;
  final String? currCountry;
  final String? domainImage;

  UserData({
    required this.userRef,
    required this.displayedName,
    required this.displayedNameLC,
    required this.bio,
    required this.domain,
    required this.fullDomainName,
    required this.domainColor,
    required this.currCounty,
    required this.currState,
    required this.currCountry,
    required this.domainImage,
    required this.groups,
    required this.modGroupsRefs,
    required this.userMessages,
    required this.savedPostsRefs,
    required this.myNotifications,
    required this.profileImage,
    required this.profileImageURL,
    required this.score,
    required this.numReports,
    required this.private,
  });
}

Future<UserData> userDataFromSnapshot(DocumentSnapshot snapshot, DocumentReference userRef, {bool? noDomainData}) async {

  final domain = snapshot.get(C.domain);
  final _domainsData = DomainsDataDatabaseService();
  DomainData? domainData;
  if (noDomainData==null || noDomainData==false) {
    domainData = await _domainsData.getDomainData(domain: domain);
  }
  if (domainData==null) domainData = DomainData(county: null, state: null, country: null, fullName: null, color: null, image: null);
  return UserData(
    userRef: userRef,
    displayedName: snapshot.get(C.displayedName),
    displayedNameLC: snapshot.get(C.displayedNameLC),
    bio: snapshot.get(C.bio),
    domain: snapshot.get(C.domain),
    groups: docRefList(snapshot.get(C.groups)),
    modGroupsRefs: docRefList(snapshot.get(C.modGroupRefs)),
    userMessages: snapshot.get(C.userMessages).map<UserMessage>((userMessage) => userMessageFromMap(map: userMessage)).toList(),
    savedPostsRefs: docRefList(snapshot.get(C.savedPostsRefs)),
    myNotifications: myNotificationList(snapshot.get(C.myNotifications)),
    profileImageURL: snapshot.get(C.profileImageURL),
    score: snapshot.get(C.score),
    numReports: snapshot.get(C.numReports),
    private: snapshot.get(C.private),
    profileImage: snapshot.get(C.profileImageURL),
    // extracted data
    fullDomainName: domainData.fullName,
    domainColor: domainData.color != null ? HexColor(domainData.color!) : null,
    currCounty: snapshot.get(C.overrideCounty) != null ? snapshot.get(C.overrideCounty) : domainData.county,
    currState: snapshot.get(C.overrideState) != null ? snapshot.get(C.overrideState) : domainData.state,
    currCountry: snapshot.get(C.overrideCountry) != null ? snapshot.get(C.overrideCountry) : domainData.country,
    domainImage: domainData.image
  );
}