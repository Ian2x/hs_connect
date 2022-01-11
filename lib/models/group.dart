import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'accessRestriction.dart';

class CountAtTime {
  final int count;
  final Timestamp time;

  CountAtTime({required this.count, required this.time});

  Map<String, dynamic> asMap() {
    return {
      C.count: count,
      C.time: time,
    };
  }
}

CountAtTime countAtTimeFromMap({required Map map}) {
  return CountAtTime(
      count: map[C.count], time: map[C.time]);
}



class Group {
  final DocumentReference groupRef;
  final DocumentReference? creatorRef;
  final List<DocumentReference> moderatorRefs;
  final String name;
  final String nameLC;
  final String? image;
  final String description;
  final AccessRestriction accessRestriction;
  final Timestamp createdAt;
  final int numPosts;
  final List<CountAtTime> postsOverTime;
  final int numMembers;
  final List<CountAtTime> membersOverTime;
  final Timestamp lastOverTimeUpdate;
  final List<DocumentReference> reportsRefs;
  final String? hexColor;

  Group({
    required this.groupRef,
    required this.creatorRef,
    required this.moderatorRefs,
    required this.name,
    required this.nameLC,
    required this.image,
    required this.description,
    required this.accessRestriction,
    required this.createdAt,
    required this.numPosts,
    required this.postsOverTime,
    required this.numMembers,
    required this.membersOverTime,
    required this.lastOverTimeUpdate,
    required this.reportsRefs,
    required this.hexColor,
  });
}

Group groupFromMap({required Map map}) {
  return Group(
    groupRef: map[C.groupRef],
    creatorRef: map[C.creatorRef],
    moderatorRefs: map[C.moderatorRefs],
    name: map[C.name],
    nameLC: map[C.nameLC],
    image: map[C.image],
    description: map[C.description],
    accessRestriction: map[C.accessRestriction],
    createdAt: map[C.createdAt],
    numPosts: map[C.numPosts],
    postsOverTime: map[C.postsOverTime],
    numMembers: map[C.numMembers],
    membersOverTime: map[C.membersOverTime],
    lastOverTimeUpdate: map[C.lastOverTimeUpdate],
    reportsRefs: map[C.reportsRefs],
    hexColor: map[C.hexColor],
  );
}

Group? groupFromSnapshot(DocumentSnapshot snapshot) {
  if (snapshot.exists) {
    final accessRestriction = snapshot.get(C.accessRestriction);
    return Group(
      groupRef: snapshot.reference,
      creatorRef: snapshot.get(C.creatorRef),
      moderatorRefs: docRefList(snapshot.get(C.moderatorRefs)),
      name: snapshot.get(C.name),
      nameLC: snapshot.get(C.nameLC),
      image: snapshot.get(C.image),
      description: snapshot.get(C.description),
      accessRestriction: accessRestrictionFromMap(accessRestriction),
      createdAt: snapshot.get(C.createdAt),
      numPosts: snapshot.get(C.numPosts),
      postsOverTime: countAtTimeList(snapshot.get(C.postsOverTime)),
      numMembers: snapshot.get(C.numMembers),
      membersOverTime: countAtTimeList(snapshot.get(C.membersOverTime)),
      lastOverTimeUpdate: snapshot.get(C.lastOverTimeUpdate),
      reportsRefs: docRefList(snapshot.get(C.reportsRefs)),
      hexColor: snapshot.get(C.hexColor),
    );
  } else {
    return null;
  }
}