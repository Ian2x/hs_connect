import 'dart:async';
import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';

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

  Future<List<Group>?> getTrendingGroups(
      {required String domain, required String county, required String state, required String country}) async {
    SplayTreeMap groupScores = new SplayTreeMap();
    // get all group ids
    final domainGroups = await groupsCollection.where('accessRestrictions', isEqualTo: AccessRestriction(restrictionType: 'domain', restriction: domain).asMap()).get();
    final countyGroups = await groupsCollection.where('county', isEqualTo: AccessRestriction(restrictionType: 'county', restriction: county).asMap()).get();
    final stateGroups = await groupsCollection.where('state', isEqualTo: AccessRestriction(restrictionType: 'state', restriction: state).asMap()).get();
    final countryGroups = await groupsCollection.where('country', isEqualTo: AccessRestriction(restrictionType: 'country', restriction: country).asMap()).get();
    final domainGroupsIds = domainGroups.docs.map((group) {
      return group.id;
    }).toList();
    final countyGroupsIds = countyGroups.docs.map((group) {
      return group.id;
    }).toList();
    final stateGroupsIds = stateGroups.docs.map((group) {
      return group.id;
    }).toList();
    final countryGroupsIds = countryGroups.docs.map((group) {
      return group.id;
    }).toList();
    print(domainGroupsIds);
    print(countyGroupsIds);
    print(stateGroupsIds);
    print(countryGroupsIds);
    // collect post information for each group
    PostsDatabaseService _posts = PostsDatabaseService(groupsId: domainGroupsIds + countyGroupsIds + stateGroupsIds + countryGroupsIds);

    // final allPosts = await _posts.multiGroupPosts;
    final allPosts = await _posts.test();
    print("========");
    print(allPosts)
    // print(allPosts.map((ele) {print(ele.toList());}));
    // print(allPosts.forEach((element) {print(element.first!.groupId);}));
    /*
    await FirebaseFirestore.instance

        .collection('posts')
        .where('groupId', whereIn: domainGroupsIds + countyGroupsIds + stateGroupsIds + countryGroupIds)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_posts._postFromDocument).toList());
    */
    return null;
  }
}
