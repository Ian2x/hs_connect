import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:flutter/material.dart';

enum MyNotificationType {
  commentToPost,
  replyToReply,
  replyToComment,
  replyVotes,
  commentVotes,
  postVotes
}

extension MyNotificationTypeExtension on MyNotificationType {
  String get string {
    switch (this) {
      case MyNotificationType.commentToPost:
        return C.commentToPost;
      case MyNotificationType.replyToReply:
        return C.replyToReply;
      case MyNotificationType.replyToComment:
        return C.replyToComment;
      case MyNotificationType.replyVotes:
        return C.replyVotes;
      case MyNotificationType.commentVotes:
        return C.commentVotes;
      case MyNotificationType.postVotes:
        return C.postVotes;
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
    case C.replyVotes:
      return MyNotificationType.replyVotes;
    case C.commentVotes:
      return MyNotificationType.commentVotes;
    case C.postVotes:
      return MyNotificationType.postVotes;
  }
  throw Exception("Given string does not match any NotificationType enum values");
}

class MyNotification {
  final DocumentReference parentPostRef;
  final MyNotificationType myNotificationType;
  final DocumentReference sourceRef;
  final DocumentReference sourceUserRef;
  final Timestamp createdAt;
  final String? extraData;

  MyNotification({
    required this.parentPostRef,
    required this.myNotificationType,
    required this.sourceRef,
    required this.sourceUserRef,
    required this.createdAt,
    required this.extraData,
  });

  Map<String, dynamic> asMap() {
    return {
      C.parentPostRef: parentPostRef,
      C.myNotificationType: myNotificationType,
      C.sourceRef: sourceRef,
      C.sourceUserRef: sourceUserRef,
      C.createdAt: createdAt,
      C.extraData: extraData,
    };
  }

  String printA(String sourceUserDisplayedName, String sourceUserFullDomainName, String postGroupName) {
    switch (myNotificationType) {
      case MyNotificationType.commentToPost:
        return '@' + sourceUserDisplayedName;
      case MyNotificationType.replyToReply:
        return '@' + sourceUserDisplayedName;
      case MyNotificationType.replyToComment:
        return '@' + sourceUserDisplayedName;
      case MyNotificationType.replyVotes:
        return '';
      case MyNotificationType.commentVotes:
        return '';
      case MyNotificationType.postVotes:
        return '';
    }
  }
  String printB(String sourceUserDisplayedName, String sourceUserFullDomainName, String postGroupName) {
    switch (myNotificationType) {
      case MyNotificationType.commentToPost:
        return ' from ';
      case MyNotificationType.replyToReply:
        return ' from ';
      case MyNotificationType.replyToComment:
        return ' from ';
      case MyNotificationType.replyVotes:
        return 'Your reply in';
      case MyNotificationType.commentVotes:
        return 'Your comment in ';
      case MyNotificationType.postVotes:
        return 'Your post in ';
    }
  }
  String printC(String sourceUserDisplayedName, String sourceUserFullDomainName, String postGroupName) {
    switch (myNotificationType) {
      case MyNotificationType.commentToPost:
        return sourceUserFullDomainName;
      case MyNotificationType.replyToReply:
        return sourceUserFullDomainName;
      case MyNotificationType.replyToComment:
        return sourceUserFullDomainName;
      case MyNotificationType.replyVotes:
        return postGroupName;
      case MyNotificationType.commentVotes:
        return postGroupName;
      case MyNotificationType.postVotes:
        return postGroupName;
    }
  }
  String printD(String sourceUserDisplayedName, String sourceUserFullDomainName, String postGroupName) {
    switch (myNotificationType) {
      case MyNotificationType.commentToPost:
        return ' commented on your post: ' + extraData!;
      case MyNotificationType.replyToReply:
        return ' replied after you: ' + extraData!;
      case MyNotificationType.replyToComment:
        return ' replied to your comment: ' + extraData!;
      case MyNotificationType.replyVotes:
        if (extraData! == '1') return ' got its first like.';
        if (extraData! == '10') return ' got 10 likes! Check it out.';
        if (extraData! == '20') return ' got 20 likes! Rare.';
        if (extraData! == '50') return ' got 50 likes! Epic.';
        if (extraData! == '100') return ' got 100 likes! Legendary.';
        return ' <Error: Unexpected data in MyNotificationType.replyVotes.extraData>';
      case MyNotificationType.commentVotes:
        if (extraData! == '1') return ' got its first like.';
        if (extraData! == '10') return ' got 10 likes! Check it out.';
        if (extraData! == '20') return ' got 20 likes! Rare.';
        if (extraData! == '50') return ' got 50 likes! Epic.';
        if (extraData! == '100') return ' got 100 likes! Legendary.';
        return ' <Error: Unexpected data in MyNotificationType.replyVotes.extraData>';
      case MyNotificationType.postVotes:
        if (extraData! == '1') return ' got its first like.';
        if (extraData! == '10') return ' got 10 likes! Check it out.';
        if (extraData! == '20') return ' got 20 likes! Check it out.';
        if (extraData! == '50') return ' got 50 likes! Check it out.';
        if (extraData! == '100') return ' got 100 likes! Legendary.';
        return '<Error: Unexpected data in MyNotificationType.replyVotes.extraData>';
    }
  }
}

MyNotification myNotificationFromMap({required Map map}) {
  return MyNotification(
      parentPostRef: map[C.parentPostRef],
      myNotificationType: myNotificationTypeFrom(map[C.myNotificationType]),
      sourceRef: map[C.sourceRef],
      sourceUserRef: map[C.sourceUserRef],
      createdAt: map[C.createdAt],
      extraData: map[C.extraData]);
}