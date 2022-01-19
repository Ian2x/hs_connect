import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:flutter/material.dart';

enum MyNotificationType { commentToPost, replyToReply, replyToComment, votes }

extension MyNotificationTypeExtension on MyNotificationType {
  String get string {
    switch (this) {
      case MyNotificationType.commentToPost:
        return C.commentToPost;
      case MyNotificationType.replyToReply:
        return C.replyToReply;
      case MyNotificationType.replyToComment:
        return C.replyToComment;
      case MyNotificationType.votes:
        return C.votes;
    }
  }
}

MyNotificationType myNotificationTypeFrom(String myNotificationType) {
  switch (myNotificationType) {
    case C.commentToPost:
      return MyNotificationType.commentToPost;
    case C.replyToReply:
      return MyNotificationType.replyToReply;
    case C.replyToComment:
      return MyNotificationType.replyToComment;
    case C.votes:
      return MyNotificationType.votes;
  }
  throw Exception("Given string does not match any NotificationType enum values");
}

class MyNotification {
  final DocumentReference parentPostRef;
  final MyNotificationType myNotificationType;
  final DocumentReference sourceRef;
  final DocumentReference sourceUserRef;
  final Timestamp createdAt;
  // extracted
  final Image? profileImage;
  final String? sourceUserDisplayedName;
  final String? sourceUserFullDomainName;

  MyNotification({
    required this.parentPostRef,
    required this.myNotificationType,
    required this.sourceRef,
    required this.sourceUserRef,
    required this.createdAt,
    required this.profileImage,
    required this.sourceUserDisplayedName,
    required this.sourceUserFullDomainName,
  });
}

Future<MyNotification> myNotificationFromMap({required Map map}) async {
  final sourceUserRef = map[C.sourceUserRef] as DocumentReference;
  final sourceUserData = await sourceUserRef.get();
  final sourceUser = await userDataFromSnapshot(sourceUserData, sourceUserRef);

  return MyNotification(
      parentPostRef: map[C.parentPostRef],
      myNotificationType: myNotificationTypeFrom(map[C.myNotificationType]),
      sourceRef: map[C.sourceRef],
      sourceUserRef: map[C.sourceUserRef],
      createdAt: map[C.createdAt],
      profileImage: sourceUser.profileImage,
      sourceUserDisplayedName: sourceUser.displayedName,
      sourceUserFullDomainName: sourceUser.fullDomainName!=null ? sourceUser.fullDomainName : sourceUser.domain
  );
}
