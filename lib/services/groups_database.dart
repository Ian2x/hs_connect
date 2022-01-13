import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';

void defaultFunc(dynamic parameter) {}

int compareDocRef(dynamic dr1, dynamic dr2) {
  return dr1.id.compareTo(dr2.id);
}

class GroupRanking {
  final Group group;
  final int score;

  GroupRanking({
    required this.group,
    required this.score,
  });
}

class GroupsDatabaseService {
  final DocumentReference currUserRef;

  GroupsDatabaseService({required this.currUserRef});

  // collection reference
  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection(C.groups);

  Future<DocumentReference> newGroup(
      {required AccessRestriction accessRestriction,
      required String name,
      required DocumentReference? creatorRef,
      required String? image,
      required String description,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    // if group already exists, just return that
    QuerySnapshot docs = await groupsCollection
        .where(C.name, isEqualTo: name)
        .where(C.accessRestriction, isEqualTo: accessRestriction.asMap())
        .get();
    if (docs.size > 0) {
      return docs.docs.first.reference;
    } else {
      DocumentReference newGroupRef = groupsCollection.doc();

      await newGroupRef
          .set({
            C.creatorRef: creatorRef,
            C.moderatorRefs: [],
            C.name: name,
            C.nameLC: name.toLowerCase(),
            C.image: image,
            C.description: description,
            C.accessRestriction: accessRestriction.asMap(),
            C.createdAt: DateTime.now(),
            C.numPosts: 0,
            C.postsOverTime: [],
            C.numMembers: 0,
            C.membersOverTime: [],
            C.lastOverTimeUpdate: DateTime.now(),
            C.reportsRefs: [],
            C.hexColor: null,
            C.selfRef: newGroupRef,
          })
          .then(onValue)
          .catchError(onError);
      if (creatorRef != null) {
        // set creator as group's creator and moderator
        newGroupRef.update({C.creatorRef: creatorRef, C.moderatorRefs: FieldValue.arrayUnion([creatorRef])});
        // set group as one of user's modGroups
        creatorRef.update({C.modGroupRefs: FieldValue.arrayUnion([newGroupRef])});
        // have creator join group
        UserDataDatabaseService _users = UserDataDatabaseService(currUserRef: creatorRef);
        await _users.joinGroup(groupRef: newGroupRef, public: true);
      }
      return newGroupRef;
    }
  }

  // get group data from groupRef
  Future<Group?> groupFromRef(DocumentReference groupRef) async {
    final snapshot = await groupRef.get();
    return groupFromSnapshot(snapshot);
  }

  void updateGroupStats({required DocumentReference groupRef}) async {
    final group = await groupFromRef(groupRef);
    if (group==null) return;
    // return if there's been an update less than 3 hours ago
    if (DateTime.now().difference(group.lastOverTimeUpdate.toDate()).compareTo(Duration(hours: maxDataCollectionRate)) < 0) return;
    // remove postCountAtTime and memberCountAtTime that are over 2 days old
    final postCountAtTimes = group.postsOverTime;
    final memberCountAtTimes = group.membersOverTime;
    postCountAtTimes.forEach((postCountAtTime) {
      if (DateTime.now().difference(postCountAtTime.time.toDate()).compareTo(Duration(days: maxDataCollectionDays)) > 0) {
        groupRef.update({C.postsOverTime: FieldValue.arrayRemove([postCountAtTime.asMap()])});
      }
    });
    memberCountAtTimes.forEach((memberCountAtTime) {
      if (DateTime.now().difference(memberCountAtTime.time.toDate()).compareTo(Duration(days: maxDataCollectionDays)) > 0) {
        groupRef.update({C.membersOverTime: FieldValue.arrayRemove([memberCountAtTime.asMap()])});
      }
    });
    // Add new postCountAtTime and memberCountAtTime
    groupRef.update({C.postsOverTime: FieldValue.arrayUnion([{C.count: group.numPosts, C.time: Timestamp.now()}])});
    groupRef.update({C.membersOverTime: FieldValue.arrayUnion([{C.count: group.numMembers, C.time: Timestamp.now()}])});
    groupRef.update({C.lastOverTimeUpdate: Timestamp.now()});
  }

  Future<List<Group>> getAllowableGroups(
      {required String domain, required String? county, required String? state, required String? country}) async {
    // get all group refs
    final Future domainGroupsFetch = groupsCollection
        .where(C.accessRestriction,
        isEqualTo: AccessRestriction(restrictionType: AccessRestrictionType.domain, restriction: domain).asMap())
        .get();
    final Future? countyGroupsFetch = county != null
        ? groupsCollection
        .where(C.accessRestriction,
        isEqualTo:
        AccessRestriction(restrictionType: AccessRestrictionType.county, restriction: county).asMap())
        .get()
        : null;
    final Future? stateGroupsFetch = state != null
        ? groupsCollection
        .where(C.accessRestriction,
        isEqualTo: AccessRestriction(restrictionType: AccessRestrictionType.state, restriction: state).asMap())
        .get()
        : null;
    final Future? countryGroupsFetch = country != null
        ? groupsCollection
        .where(C.accessRestriction,
        isEqualTo:
        AccessRestriction(restrictionType: AccessRestrictionType.country, restriction: country).asMap())
        .get()
        : null;
    final QuerySnapshot domainGroupsSnapshots= await domainGroupsFetch;
    final QuerySnapshot? countyGroupsSnapshots = await countyGroupsFetch;
    final QuerySnapshot? stateGroupsSnapshots = await stateGroupsFetch;
    final QuerySnapshot? countryGroupsSnapshots = await countryGroupsFetch;
    var allowableGroups = domainGroupsSnapshots.docs.map((snapshot) => groupFromSnapshot(snapshot)).toList();
    allowableGroups.removeWhere((value) => value==null);
    if (countyGroupsSnapshots != null) {
      var countyGroups = countyGroupsSnapshots.docs.map((snapshot) => groupFromSnapshot(snapshot)).toList();
      countyGroups.removeWhere((value) => value==null);
      allowableGroups.addAll(countyGroups);
    }
    if (stateGroupsSnapshots != null) {
      var stateGroups = stateGroupsSnapshots.docs.map((snapshot) => groupFromSnapshot(snapshot)).toList();
      stateGroups.removeWhere((value) => value==null);
      allowableGroups.addAll(stateGroups);
    }
    if (countryGroupsSnapshots != null) {
      var countryGroups = countryGroupsSnapshots.docs.map((snapshot) => groupFromSnapshot(snapshot)).toList();
      countryGroups.removeWhere((value) => value==null);
      allowableGroups.addAll(countryGroups);
    }
    return allowableGroups.cast<Group>();
  }

  Future<List<DocumentReference>> getAllowableGroupRefs(
      {required String domain, required String? county, required String? state, required String? country}) async {
    return (await getAllowableGroups(domain: domain, county: county, state: state, country: country))
        .map((group) => group.groupRef)
        .toList();
  }

  Future<Group?> getGroup(DocumentReference groupRef) async {
    return groupFromSnapshot(await groupRef.get());
  }


  Future _getUserGroupsHelper(UserGroup UGR, int index, List<Group?> results) async {
    results[index] = await getGroup(UGR.groupRef);
  }

  // returns sorted by oldest groups first (domain first)
  Future<List<Group?>> getUserGroups({required List<UserGroup> userGroups}) async {
    List<Group?> results = List.filled(userGroups.length, null);
    await Future.wait([for (int i=0; i<userGroups.length; i++) _getUserGroupsHelper(userGroups[i], i, results)]);
    results.sort((a,b) => (a as Group).createdAt.compareTo((b as Group).createdAt));
    return results;
  }

  Future _getGroupsHelper(DocumentReference GR, int index, List<Group?> results) async {
    results[index] = await getGroup(GR);
  }

  // preserves order
  Future<List<Group?>> getGroups({required List<DocumentReference> groupsRefs}) async {
    List<Group?> results = List.filled(groupsRefs.length, null);
    await Future.wait([for (int i=0; i<groupsRefs.length; i++) _getGroupsHelper(groupsRefs[i], i, results)]);
    return results;
  }

  Future<List<Group>> getTrendingGroups(
      {required String domain, required String? county, required String? state, required String? country}) async {
    // get all group refs
    final allowableGroups = await getAllowableGroups(domain: domain, county: county, state: state, country: country);
    List<GroupRanking> groupRankings = <GroupRanking>[];
    allowableGroups.forEach((group) {
      int score = 0;
      List<CountAtTime> pot = group.postsOverTime;
      if (pot.isNotEmpty) {
        pot.sort((a,b) => a.time.compareTo(b.time));
        score+=pot[0].count;
      }
      List<CountAtTime> mot = group.membersOverTime;
      if (mot.isNotEmpty) {
        mot.sort((a,b) => a.time.compareTo(b.time));
        score+=mot[0].count;
      }
      groupRankings.add(GroupRanking(group: group, score: score));
    });
    groupRankings.sort((a,b) => b.score-a.score);
    return groupRankings.map((groupRanking) => groupRanking.group).toList();
  }

  SearchResult _searchResultFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    return SearchResult(
      resultRef: querySnapshot.reference,
      resultType: SearchResultType.groups,
      resultDescription: querySnapshot[C.createdAt].toString(),
      resultText: querySnapshot[C.name],
    );
  }

  Stream<List<SearchResult>> searchStream(String searchKey, List<DocumentReference> allowableGroupRefs) {
    final searchKeyLC = searchKey.toLowerCase();
    if (allowableGroupRefs.length == 0) return Stream.empty();
    return groupsCollection
        .where(C.selfRef, whereIn: allowableGroupRefs)
        .where(C.nameLC, isGreaterThanOrEqualTo: searchKeyLC)
        .where(C.nameLC, isLessThan: searchKeyLC + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_searchResultFromQuerySnapshot).toList());
  }
}
