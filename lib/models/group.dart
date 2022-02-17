import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/services/domains_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'accessRestriction.dart';
import 'domainData.dart';

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
  String name;
  final String nameLC;
  final String? image;
  final String description;
  final AccessRestriction accessRestriction;
  final Timestamp createdAt;
  final int numPosts;
  final List<CountAtTime> postsOverTime;
  final int numMembers;
  final List<CountAtTime> membersOverTime;
  final int numReports;
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
    required this.numReports,
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
    numReports: map[C.numReports],
    hexColor: map[C.hexColor],
  );
}

Future<Group?> groupFromSnapshot(DocumentSnapshot snapshot) async {
  if (snapshot.exists) {
    final accessRestrictionData = snapshot.get(C.accessRestriction);
    final accessRestriction = accessRestrictionFromMap(accessRestrictionData);
    DomainData? domainData;
    if (accessRestriction.restrictionType==AccessRestrictionType.domain) {
      final _domainsData = DomainsDataDatabaseService();
      domainData = await _domainsData.getDomainData(domain: snapshot.get(C.name));
    }
    if (domainData==null) domainData = DomainData(county: null, state: null, country: null, fullName: null, color: null, image: null, launchDate: null);
    final temp = Group(
      groupRef: snapshot.reference,
      creatorRef: snapshot.get(C.creatorRef),
      moderatorRefs: docRefList(snapshot.get(C.moderatorRefs)),
      name: domainData.fullName!=null ? domainData.fullName : snapshot.get(C.name),
      nameLC: snapshot.get(C.nameLC),
      image: domainData.image!=null ? domainData.image : snapshot.get(C.image),
      description: snapshot.get(C.description),
      accessRestriction: accessRestriction,
      createdAt: snapshot.get(C.createdAt),
      numPosts: snapshot.get(C.numPosts),
      postsOverTime: countAtTimeList(snapshot.get(C.postsOverTime)),
      numMembers: snapshot.get(C.numMembers),
      membersOverTime: countAtTimeList(snapshot.get(C.membersOverTime)),
      numReports: snapshot.get(C.numReports),
      hexColor: domainData.color!=null ? domainData.color : snapshot.get(C.hexColor),
    );
    return temp;
  } else {
    return null;
  }
}