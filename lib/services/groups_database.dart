import 'dart:async';
import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/idRanking.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:hs_connect/shared/constants.dart';

void defaultFunc(dynamic parameter) {}

class GroupsDatabaseService {
  final String? userId;

  GroupsDatabaseService({this.userId});

  // collection reference
  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('groups');

  Future newGroup(
      {required AccessRestriction accessRestrictions,
      required String name,
      required String userId,
      String? image = '',
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    QuerySnapshot docs = await groupsCollection
        .where('name', isEqualTo: name)
        .where('accessRestrictions', isEqualTo: accessRestrictions.asMap())
        .get();
    if (docs.size > 0) {
      return docs.docs.first.id;
    } else {
      DocumentReference docRef = await groupsCollection.doc();
      final docId = docRef.id;

      await groupsCollection
          .doc(docId)
          .set({
            'accessRestrictions': accessRestrictions.asMap(),
            'name': name,
            'userId': userId,
            'image': image,
          })
          .then(onValue)
          .catchError(onError);
      UserInfoDatabaseService _users = UserInfoDatabaseService();
      await _users.joinGroup(userId: userId, groupId: docId, public: true);
      return docId;
    }
  }

  // get group data
  Future getGroupData({required String groupId}) async {
    final snapshot = await groupsCollection.doc(groupId).get();
    return _groupDataFromSnapshot(snapshot, groupId: groupId);
  }

  // home data from snapshot
  Group? _groupDataFromSnapshot(DocumentSnapshot snapshot, {required String groupId}) {
    if (snapshot.exists) {
      final accessRestrictions = snapshot.get('accessRestrictions');
      return Group(
        groupId: groupId,
        userId: snapshot.get('userId'),
        name: snapshot.get('name'),
        image: snapshot.get('image'),
        accessRestrictions: AccessRestriction(
            restriction: accessRestrictions['restriction'],
            restrictionType: accessRestrictions[
                'restrictionType']), //AccessRestriction.hashmapToAR(hashMap: snapshot.get('accessRestrictions') as HashMap<String, dynamic>),
      );
    } else {
      return null;
    }
  }

  // get group data from groupId
  Future<Group?> group({required String groupId}) async {
    await groupsCollection.doc(groupId).get().then((DocumentSnapshot documentSnapshot) {
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
              return userGroup.groupId;
            }).toList())
        .get();
  }

  Future getTrendingGroups(
      {required String domain, required String? county, required String? state, required String? country}) async {
    SplayTreeMap groupScores = new SplayTreeMap();
    // get all group ids
    final domainGroups = await groupsCollection.where('accessRestrictions', isEqualTo: AccessRestriction(restrictionType: 'domain', restriction: domain).asMap()).get();
    final countyGroups = county!=null ? await groupsCollection.where('county', isEqualTo: AccessRestriction(restrictionType: 'county', restriction: county).asMap()).get() : null;
    final stateGroups = state!=null ? await groupsCollection.where('state', isEqualTo: AccessRestriction(restrictionType: 'state', restriction: state).asMap()).get() : null;
    final countryGroups = country!=null ? await groupsCollection.where('country', isEqualTo: AccessRestriction(restrictionType: 'country', restriction: country).asMap()).get(): null;
    final domainGroupsIds = domainGroups.docs.map((group) {
      return group.id;
    }).toList();
    final countyGroupsIds = countyGroups!=null ? countyGroups.docs.map((group) {
      return group.id;
    }).toList() : <String>[];
    final stateGroupsIds = stateGroups!=null ? stateGroups.docs.map((group) {
      return group.id;
    }).toList() : <String>[];
    final countryGroupsIds = countryGroups!=null ? countryGroups.docs.map((group) {
      return group.id;
    }).toList() : <String>[];
    // collect post information for each group
    print(domainGroupsIds + countyGroupsIds + stateGroupsIds + countryGroupsIds);
    PostsDatabaseService _posts = PostsDatabaseService(groupsId: domainGroupsIds + countyGroupsIds + stateGroupsIds + countryGroupsIds);


    final List<Post?> allPosts = await _posts.getMultiGroupPosts();

    final List<Post?> filteredPosts = allPosts.where((post) => post!=null && DateTime.now().difference(post.createdAt.toDate()).compareTo(Duration(days: 3))==-1).toList();


    filteredPosts.forEach((post) {
      groupScores.update(post!.groupId, (value) => value+1, ifAbsent: () => 1);
    });

    // print(groupScores);
    List<idRanking> groupScoresList = groupScores.entries.map((ele) => idRanking(id: ele.key, count: ele.value)).toList();
    groupScoresList.sort(idRankingCompare);

    return groupsCollection
        .where(FieldPath.documentId,
        whereIn: groupScoresList.map((idRanking) {
          return idRanking.id;
        }).toList())
        .get();

    return null;
  }
}
