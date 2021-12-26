import 'dart:async';
import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/refRanking.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:hs_connect/shared/constants.dart';

void defaultFunc(dynamic parameter) {}

class GroupsDatabaseService {
  final DocumentReference? userRef;

  GroupsDatabaseService({this.userRef});

  // collection reference
  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('groups');

  Future newGroup(
      {required AccessRestriction accessRestrictions,
      required String name,
      DocumentReference? userRef,
      String? image,
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
            'userRef': userRef,
            'name': name,
            'image': image,
            'accessRestrictions': accessRestrictions.asMap(),
            'createdAt': DateTime.now(),
            'numPosts': 0,
          })
          .then(onValue)
          .catchError(onError);
      if (userRef != null) {
        UserInfoDatabaseService _users = UserInfoDatabaseService(userRef: userRef);
        await _users.joinGroup(userRef: userRef, groupRef: newGroupRef, public: true);
      }
      return newGroupRef;
    }
  }

  // get group data
  Future getGroupData({required DocumentReference groupRef}) async {
    final snapshot = await groupRef.get();
    return _groupDataFromSnapshot(snapshot: snapshot, groupRef: groupRef);
  }

  // home data from snapshot
  Group? _groupDataFromSnapshot({required DocumentSnapshot snapshot, required DocumentReference groupRef}) {
    if (snapshot.exists) {
      final accessRestrictions = snapshot.get('accessRestrictions');
      return Group(
        groupRef: groupRef,
        userRef: snapshot.get('userRef'),
        name: snapshot.get('name'),
        image: snapshot.get('image'),
        // AccessRestriction.mapToAR(map: snapshot.get('accessRestrictions') as Map<String, dynamic>),
        accessRestrictions: AccessRestriction(
            restriction: accessRestrictions['restriction'],
            restrictionType: accessRestrictions[
                'restrictionType']),
        createdAt: snapshot.get('createdAt'),
        numPosts: snapshot.get('numPosts'),
      );
    } else {
      return null;
    }
  }

  // get group data from groupRef
  Future<Group?> group({required DocumentReference groupRef}) async {
    await groupRef.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot.data();
      } else {
        return null;
      }
    });
  }

  // for converting userGroups to Groups, must be wrapped in FutureBuilder (see post_form for reference)
  Future<QuerySnapshot<Object?>> getGroups({required List<UserGroup> userGroups}) async {
    return groupsCollection
        .where(FieldPath.documentId,
            whereIn: userGroups.map((userGroup) {
              return userGroup.groupRef.id;
            }).toList())
        .get();
  }

  Future<QuerySnapshot<Object?>> getTrendingGroups(
      {required String domain, required String? county, required String? state, required String? country}) async {
    SplayTreeMap groupScores = new SplayTreeMap();
    // get all group refs
    final domainGroups = await groupsCollection
        .where('accessRestrictions',
            isEqualTo: AccessRestriction(restrictionType: 'domain', restriction: domain).asMap())
        .get();
    final countyGroups = county != null
        ? await groupsCollection
            .where('county', isEqualTo: AccessRestriction(restrictionType: 'county', restriction: county).asMap())
            .get()
        : null;
    final stateGroups = state != null
        ? await groupsCollection
            .where('state', isEqualTo: AccessRestriction(restrictionType: 'state', restriction: state).asMap())
            .get()
        : null;
    final countryGroups = country != null
        ? await groupsCollection
            .where('country', isEqualTo: AccessRestriction(restrictionType: 'country', restriction: country).asMap())
            .get()
        : null;
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
    // collect post information for each group
    PostsDatabaseService _posts =
        PostsDatabaseService(groupsRefs: domainGroupsRefs + countyGroupsRefs + stateGroupsRefs + countryGroupsRefs);
    print(domainGroupsRefs + countyGroupsRefs + stateGroupsRefs + countryGroupsRefs);
    final List<Post?> allPosts = await _posts.getMultiGroupPosts();
    print(allPosts);
    print("LOKI ABOVE");
    final List<Post?> filteredPosts = allPosts
        .where((post) =>
            post != null && DateTime.now().difference(post.createdAt.toDate()).compareTo(Duration(days: 3)) == -1)
        .toList();
    print(filteredPosts);
    filteredPosts.forEach((post) {
      print("look");
      print(post!.groupRef);
      groupScores.update(post!.groupRef, (value) => value + 1, ifAbsent: () => 1);

    });

    print(groupScores);
    List<refRanking> groupScoresList =
        groupScores.entries.map((ele) => refRanking(ref: ele.key, count: ele.value)).toList();
    groupScoresList.sort(refRankingCompare);
    print(groupScoresList);
    return groupsCollection
        .where(FieldPath.documentId,
            whereIn: groupScoresList.map((refRanking) {
              return refRanking.ref.id;
            }).toList())
        .get();
  }
}
