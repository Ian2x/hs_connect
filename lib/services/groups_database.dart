import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/ref_ranking.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';

void defaultFunc(dynamic parameter) {}

int compareDocRef(dynamic dr1, dynamic dr2) {
  return dr1.id.compareTo(dr2.id);
}

class GroupsDatabaseService {
  final DocumentReference? userRef;

  GroupsDatabaseService({this.userRef});

  // collection reference
  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('groups');


  Future<DocumentReference> newGroup(
      {required AccessRestriction accessRestrictions,
      required String name,
      required DocumentReference? creatorRef,
      required String? image,
      required String? description,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {

    QuerySnapshot docs = await groupsCollection
        .where('name', isEqualTo: name)
        .where('accessRestrictions', isEqualTo: accessRestrictions.asMap())
        .get();
    if (docs.size > 0) {
      return docs.docs.first.reference;
    } else {
      DocumentReference newGroupRef = await groupsCollection.doc();

      await newGroupRef
          .set({
            'creatorRef': creatorRef,
            'moderatorRefs': [],
            'name': name,
            'image': image,
            'description': description,
            'accessRestrictions': accessRestrictions.asMap(),
            'createdAt': DateTime.now(),
            'numPosts': 0,
            'numMembers': 0,
          })
          .then(onValue)
          .catchError(onError);
      if (creatorRef != null) {
        UserDataDatabaseService _users = UserDataDatabaseService(userRef: creatorRef);
        newGroupRef.update({'numMembers': FieldValue.increment(1)});
        await _users.joinGroup(userRef: creatorRef, groupRef: newGroupRef, public: true);
      }
      return newGroupRef;
    }
  }

  // get group data
  Future<Group?> getGroupData({required DocumentReference groupRef}) async {
    final snapshot = await groupRef.get();
    return _groupDataFromSnapshot(snapshot: snapshot);
  }

  Future<List<DocumentReference>> getAllowableGroupRefs({required String domain, required String? county, required String? state, required String? country}) async {
    // get all group refs
    final domainGroupsFetch = groupsCollection
        .where('accessRestrictions',
        isEqualTo: AccessRestriction(restrictionType: 'domain', restriction: domain).asMap())
        .get();
    final countyGroupsFetch = county != null
        ? groupsCollection
        .where('county', isEqualTo: AccessRestriction(restrictionType: 'county', restriction: county).asMap())
        .get()
        : null;
    final stateGroupsFetch = state != null
        ? groupsCollection
        .where('state', isEqualTo: AccessRestriction(restrictionType: 'state', restriction: state).asMap())
        .get()
        : null;
    final countryGroupsFetch = country != null
        ? groupsCollection
        .where('country', isEqualTo: AccessRestriction(restrictionType: 'country', restriction: country).asMap())
        .get()
        : null;
    final domainGroups = await domainGroupsFetch;
    final countyGroups = await countyGroupsFetch;
    final stateGroups = await stateGroupsFetch;
    final countryGroups = await countryGroupsFetch;
    final domainGroupsRefs = domainGroups.docs.map((group) {
      return group.reference;
    }).toList();
    final countyGroupsRefs = countyGroups != null
        ? countyGroups.docs.map((group) {
      return group.reference;
    }).toList()
        : <DocumentReference>[];
    final stateGroupsRefs = stateGroups != null
        ? stateGroups.docs.map((group) {
      return group.reference;
    }).toList()
        : <DocumentReference>[];
    final countryGroupsRefs = countryGroups != null
        ? countryGroups.docs.map((group) {
      return group.reference;
    }).toList()
        : <DocumentReference>[];
    return domainGroupsRefs + countyGroupsRefs + stateGroupsRefs + countryGroupsRefs;
}

  // home data from snapshot
  Group? _groupDataFromSnapshot({required DocumentSnapshot snapshot}) {
    if (snapshot.exists) {
      final accessRestrictions = snapshot.get('accessRestrictions');
      final test = Group(
        groupRef: snapshot.reference,
        creatorRef: snapshot.get('creatorRef'),
        name: snapshot.get('name'),
        image: snapshot.get('image'),
        description: snapshot.get('description'),
        accessRestrictions: AccessRestriction(
            restriction: accessRestrictions['restriction'],
            restrictionType: accessRestrictions['restrictionType']),
        createdAt: snapshot.get('createdAt'),
        numPosts: snapshot.get('numPosts'),
        moderatorRefs: (snapshot.get('moderatorRefs') as List).map((item) => item as DocumentReference).toList(),
        numMembers: snapshot.get('numMembers'),
      );
      return test;
    } else {
      return null;
    }
  }

  // get group data from groupRef
  Future<Group?> group({required DocumentReference groupRef}) async {
    final snapshot = await groupRef.get();
    return _groupDataFromSnapshot(snapshot: snapshot);
  }

  // for converting userGroups to Groups, must be wrapped in FutureBuilder (see post_form for reference)
  Future<QuerySnapshot> getGroups({required List<UserGroup> userGroups}) async {
    return groupsCollection
        .where(FieldPath.documentId,
            whereIn: userGroups.map((userGroup) {
              return userGroup.groupRef.id;
            }).toList())
        .get();
  }

  Future<List<Group?>> getAllowableGroups({required UserData userData}) async {
    final allowableGroupRefs = await getAllowableGroupRefs(domain: userData.domain, county: userData.county, state: userData.state, country: userData.country);
    return await Future.wait(allowableGroupRefs.map((item) async {return await group(groupRef: item);}));
  }

  Future<QuerySnapshot> getTrendingGroups(
      {required String domain, required String? county, required String? state, required String? country}) async {

    SplayTreeMap groupScores = new SplayTreeMap(compareDocRef);
    // get all group refs
    final allGroupsRefs = await getAllowableGroupRefs(domain: domain, county: county, state: state, country: country);
    // collect post information for each group
    PostsDatabaseService _posts =
        PostsDatabaseService(groupRefs: allGroupsRefs);
    final List<Post?> allPosts = await _posts.getMultiGroupPosts();
    final List<Post?> filteredPosts = allPosts
        .where((post) =>
            post != null && DateTime.now().difference(post.createdAt.toDate()).compareTo(Duration(days: daysTrending)) == -1)
        .toList();
    filteredPosts.forEach((post) {
      if (post!= null) {
        groupScores.update(post.groupRef, (value) => value + 1, ifAbsent: () => 1);
      }
    });

    List<refRanking> groupScoresList =
        groupScores.entries.map((ele) => refRanking(ref: ele.key, count: ele.value)).toList();
    groupScoresList.sort(refRankingCompare);
    return groupsCollection
        .where(FieldPath.documentId,
            whereIn: groupScoresList.map((refRanking) {
              return refRanking.ref.id;
            }).toList())
        .get();
  }
}
