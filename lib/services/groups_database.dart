import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/searchResult.dart';
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
  static final CollectionReference groupsCollection = FirebaseFirestore.instance.collection(C.groups);

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
      DocumentReference newGroupRef;
      if (accessRestriction.restrictionType==AccessRestrictionType.domain) {
        newGroupRef = groupsCollection.doc(name);
      } else {
        newGroupRef = groupsCollection.doc();
      }

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
            C.numReports: 0,
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
        await _users.joinGroup(groupRef: newGroupRef);
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

  Future<Group?> getGroup(DocumentReference groupRef) async {
    return groupFromSnapshot(await groupRef.get());
  }

  Future _getGroupsHelper(DocumentReference GR, int index, List<Group?> results) async {
    results[index] = await getGroup(GR);
  }

  // preserves order and adds on public group at end
  Future<List<Group?>> getGroups({required List<DocumentReference> groupsRefs, required bool withPublic}) async {
    int listLength = withPublic ? groupsRefs.length+1 : groupsRefs.length;
    Future<Group?>? publicGroupData;
    if (withPublic) {
      publicGroupData = getGroup(groupsCollection.doc(C.Public));
    }
    List<Group?> results = List.filled(listLength, null);
    await Future.wait([for (int i=0; i<groupsRefs.length; i++) _getGroupsHelper(groupsRefs[i], i, results)]);
    if (withPublic) {
      final publicGroup = await publicGroupData;
      results[groupsRefs.length] = publicGroup;
    }
    return results;
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
