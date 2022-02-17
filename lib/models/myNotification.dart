import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';

enum MyNotificationType {
  commentToPost,
  replyToReply,
  replyToComment,
  replyVotes,
  commentVotes,
  postVotes,
  fromMe,
  featuredPost,
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
      case MyNotificationType.fromMe:
        return C.fromMe;
      case MyNotificationType.featuredPost:
        return C.featuredPost;
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
    case C.fromMe:
      return MyNotificationType.fromMe;
    case C.featuredPost:
      return MyNotificationType.featuredPost;
  }
  throw Exception("Given string does not match any NotificationType enum values");
}

class MyNotification {
  final DocumentReference parentPostRef;
  final MyNotificationType myNotificationType;
  final DocumentReference sourceRef;
  final DocumentReference sourceUserRef;
  final DocumentReference notifiedUserRef;
  final Timestamp createdAt;
  final String? extraData;

  MyNotification({
    required this.parentPostRef,
    required this.myNotificationType,
    required this.sourceRef,
    required this.sourceUserRef,
    required this.notifiedUserRef,
    required this.createdAt,
    required this.extraData,
  });

  Map<String, dynamic> asMap() {
    return {
      C.parentPostRef: parentPostRef,
      C.myNotificationType: myNotificationType.string,
      C.sourceRef: sourceRef,
      C.sourceUserRef: sourceUserRef,
      C.createdAt: createdAt,
      C.extraData: extraData,
    };
  }

  String printA(String sourceUserName, String postGroupName) {
    switch (myNotificationType) {
      case MyNotificationType.commentToPost:
        return sourceUserName;
      case MyNotificationType.replyToReply:
        return sourceUserName;
      case MyNotificationType.replyToComment:
        return sourceUserName;
      case MyNotificationType.replyVotes:
        return '';
      case MyNotificationType.commentVotes:
        return '';
      case MyNotificationType.postVotes:
        return '';
      case MyNotificationType.fromMe:
        return '';
      case MyNotificationType.featuredPost:
        return '';
    }
  }
  String printB(String sourceUserName, String postGroupName) {
    switch (myNotificationType) {
      case MyNotificationType.commentToPost:
        return '';
      case MyNotificationType.replyToReply:
        return '';
      case MyNotificationType.replyToComment:
        return '';
      case MyNotificationType.replyVotes:
        return 'Your reply in ';
      case MyNotificationType.commentVotes:
        return 'Your comment in ';
      case MyNotificationType.postVotes:
        return 'Your post in ';
      case MyNotificationType.fromMe:
        return '';
      case MyNotificationType.featuredPost:
        return '';
    }
  }
  String printC(String sourceUserName, String postGroupName) {
    switch (myNotificationType) {
      case MyNotificationType.commentToPost:
        return '';
      case MyNotificationType.replyToReply:
        return '';
      case MyNotificationType.replyToComment:
        return '';
      case MyNotificationType.replyVotes:
        return postGroupName;
      case MyNotificationType.commentVotes:
        return postGroupName;
      case MyNotificationType.postVotes:
        return postGroupName;
      case MyNotificationType.fromMe:
        return '';
      case MyNotificationType.featuredPost:
        return '';
    }
  }
  String printD(String sourceUserDisplayedName, String postGroupName) {
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
        if (extraData! == '20') return ' got 20 likes! Rare.';
        if (extraData! == '50') return ' got 50 likes! Epic.';
        if (extraData! == '100') return ' got 100 likes! Legendary.';
        return '<Error: Unexpected data in MyNotificationType.replyVotes.extraData>';
      case MyNotificationType.fromMe:
        return '';
      case MyNotificationType.featuredPost:
        return extraData!=null ? extraData! : 'ummm something went wrong :/';
    }
  }
}

MyNotification myNotificationFromMap({required Map map}) {
  return MyNotification(
      parentPostRef: map[C.parentPostRef],
      myNotificationType: myNotificationTypeFrom(map[C.myNotificationType]),
      sourceRef: map[C.sourceRef],
      sourceUserRef: map[C.sourceUserRef],
      notifiedUserRef: map[C.notifiedUserRef],
      createdAt: map[C.createdAt],
      extraData: map[C.extraData]);
}

MyNotification myNotificationFromSnapshot(DocumentSnapshot snapshot) {
  return MyNotification(
    parentPostRef: snapshot.get(C.parentPostRef),
    myNotificationType: myNotificationTypeFrom(snapshot.get(C.myNotificationType)),
    sourceRef: snapshot.get(C.sourceRef),
    sourceUserRef: snapshot.get(C.sourceUserRef),
    notifiedUserRef: snapshot.get(C.notifiedUserRef),
    createdAt: snapshot.get(C.createdAt),
    extraData: snapshot.get(C.extraData)
  );
}
