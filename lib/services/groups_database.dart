import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';

void defaultFunc(dynamic parameter) {}

int compareDocRef(dynamic dr1, dynamic dr2) {
  return dr1.id.compareTo(dr2.id);
}

class refRanking {
  final DocumentReference ref;
  final int count;

  refRanking({
    required this.ref,
    required this.count,
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
      required String? description,
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
            C.numMembers: 0,
            C.reportsRefs: [],
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
        newGroupRef.update({C.numMembers: FieldValue.increment(1)});
        await _users.joinGroup(userRef: creatorRef, groupRef: newGroupRef, public: true);
      }
      return newGroupRef;
    }
  }

  // get group data
  Future<Group?> getGroupData({required DocumentReference groupRef}) async {
    final snapshot = await groupRef.get();
    return groupDataFromSnapshot(snapshot: snapshot);
  }

  Future<List<DocumentReference>> getAllowableGroupRefs(
      {required String domain, required String? county, required String? state, required String? country}) async {
    // get all group refs
    final Future domainGroupsFetch = groupsCollection
        .where(C.accessRestriction,
            isEqualTo: AccessRestriction(restrictionType: AccessRestrictionType.domain, restriction: domain).asMap())
        .get();
    final Future? countyGroupsFetch = county != null
        ? groupsCollection
            .where(C.county,
                isEqualTo:
                    AccessRestriction(restrictionType: AccessRestrictionType.county, restriction: county).asMap())
            .get()
        : null;
    final Future? stateGroupsFetch = state != null
        ? groupsCollection
            .where(C.state,
                isEqualTo: AccessRestriction(restrictionType: AccessRestrictionType.state, restriction: state).asMap())
            .get()
        : null;
    final Future? countryGroupsFetch = country != null
        ? groupsCollection
            .where(C.country,
                isEqualTo:
                    AccessRestriction(restrictionType: AccessRestrictionType.country, restriction: country).asMap())
            .get()
        : null;
    final QuerySnapshot domainGroups = await domainGroupsFetch;
    final QuerySnapshot? countyGroups = await countyGroupsFetch;
    final QuerySnapshot? stateGroups = await stateGroupsFetch;
    final QuerySnapshot? countryGroups = await countryGroupsFetch;
    final List<DocumentReference> domainGroupsRefs = domainGroups.docs.map((group) {
      return group.reference;
    }).toList();
    final List<DocumentReference> countyGroupsRefs = countyGroups != null
        ? countyGroups.docs.map((group) {
            return group.reference;
          }).toList()
        : <DocumentReference>[];
    final List<DocumentReference> stateGroupsRefs = stateGroups != null
        ? stateGroups.docs.map((group) {
            return group.reference;
          }).toList()
        : <DocumentReference>[];
    final List<DocumentReference> countryGroupsRefs = countryGroups != null
        ? countryGroups.docs.map((group) {
            return group.reference;
          }).toList()
        : <DocumentReference>[];
    return domainGroupsRefs + countyGroupsRefs + stateGroupsRefs + countryGroupsRefs;
  }

  // home data from snapshot
  Group? groupDataFromSnapshot({required DocumentSnapshot snapshot}) {
    if (snapshot.exists) {
      return Group.fromSnapshot(snapshot);
    } else {
      return null;
    }
  }

  // get group data from groupRef
  Future<Group?> group({required DocumentReference groupRef}) async {
    final snapshot = await groupRef.get();
    return groupDataFromSnapshot(snapshot: snapshot);
  }

  Future<List<Group>> getGroups({required List<UserGroup> userGroups}) async {
    final Iterable<DocumentReference> groupRefs = userGroups.map((userGroup) => userGroup.groupRef);
    List<Group> result = <Group>[];
    await Future.forEach(groupRefs, (item) async {
      final temp = await group(groupRef: item as DocumentReference);
      if (temp!=null) result.add(temp);
    });
    return result;
  }

  Future<List<Group?>> getAllowableGroups({required UserData userData}) async {
    final List<DocumentReference> allowableGroupRefs = await getAllowableGroupRefs(
        domain: userData.domain, county: userData.county, state: userData.state, country: userData.country);
    List<Group> result = <Group>[];
    await Future.forEach(allowableGroupRefs, (groupRef) async {
      final temp = await group(groupRef: groupRef as DocumentReference);
      if (temp!=null) result.add(temp);
    });
    return result;
  }

  Future<QuerySnapshot> getTrendingGroups(
      {required String domain, required String? county, required String? state, required String? country}) async {
    //TODO: replace with tracking numPosts and numMembers over time
    SplayTreeMap groupScores = new SplayTreeMap(compareDocRef);
    // get all group refs
    final allGroupsRefs = await getAllowableGroupRefs(domain: domain, county: county, state: state, country: country);
    // collect post information for each group
    PostsDatabaseService _posts = PostsDatabaseService(groupRefs: allGroupsRefs, currUserRef: currUserRef);
    final List<Post?> allPosts = await _posts.getMultiGroupPosts();
    final List<Post?> filteredPosts = allPosts
        .where((post) =>
            post != null &&
            DateTime.now().difference(post.createdAt.toDate()).compareTo(Duration(days: daysTrending)) == -1)
        .toList();
    filteredPosts.forEach((post) {
      if (post != null) {
        groupScores.update(post.groupRef, (value) => value + 1, ifAbsent: () => 1);
      }
    });
    List<refRanking> groupScoresList =
        groupScores.entries.map((ele) => refRanking(ref: ele.key, count: ele.value)).toList();
    groupScoresList.sort((a, b) {return b.count - a.count;});
    List<refRanking> shortGroupScoresList = groupScoresList.sublist(0, min(10, groupScoresList.length));
    final test = groupsCollection
        .where(FieldPath.documentId,
            whereIn: shortGroupScoresList.map((refRanking) {
              return refRanking.ref.id;
            }).toList())
        .get();
    return test;
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
    final LCsearchKey = searchKey.toLowerCase();
    if (allowableGroupRefs.length == 0) return Stream.empty();
    return groupsCollection
        .where(C.selfRef, whereIn: allowableGroupRefs)
        .where(C.nameLC, isGreaterThanOrEqualTo: LCsearchKey)
        .where(C.nameLC, isLessThan: LCsearchKey + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_searchResultFromQuerySnapshot).toList());
  }
}
