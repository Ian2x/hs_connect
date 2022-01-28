import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/constants.dart';

class UserDataDatabaseService {
  DocumentReference currUserRef;

  UserDataDatabaseService({required this.currUserRef});

  // collection reference
  final CollectionReference userDataCollection = FirebaseFirestore.instance.collection(C.userData);

  Future<void> initUserData(String domain, String username, {String? overrideCounty, String? overrideState, String? overrideCountry}) async {
    final domainLC = domain.toLowerCase();
    final GroupsDatabaseService _groupDatabaseService = GroupsDatabaseService(currUserRef: currUserRef);

    // Create domain group if not already created
    final domainGroupRef = await _groupDatabaseService.newGroup(
        accessRestriction: AccessRestriction(restrictionType: AccessRestrictionType.domain, restriction: domainLC),
        name: domainLC,
        image: null,
        description: 'Default group for ' + domainLC,
        creatorRef: null);

    final domainsDataRef = FirebaseFirestore.instance.collection(C.domainsData).doc(domainLC);
    domainsDataRef.get().then((doc) => {
      if (!doc.exists) {
        domainsDataRef.set({C.color: null, C.country: null, C.county: null, C.fullName: null, C.state: null, C.image: null})
      }
    });

    await currUserRef.set({
      C.displayedName: username,
      C.displayedNameLC: username.toLowerCase(),
      C.bio: null,
      C.domain: domainLC,
      C.overrideCounty: overrideCounty,
      C.overrideState: overrideState,
      C.overrideCountry: overrideCountry,
      C.groups: [domainGroupRef],
      C.modGroupRefs: [],
      C.userMessages: [],
      C.myNotifications: [],
      C.savedPostsRefs: [],
      C.profileImageURL: null,
      C.score: 0,
      C.numReports: 0,
      C.private: false,
    });
    // join domain group
    await joinGroup(groupRef: domainGroupRef);
  }

  Future<void> updateProfile(
      {required String displayedName,
      required String? imageURL,
      required Function(void) onValue,
      required Function onError}) async {
    return await currUserRef
        .update({
          C.displayedName: displayedName,
          C.displayedNameLC: displayedName.toLowerCase(),
          C.profileImageURL: imageURL,
        })
        .then(onValue)
        .catchError(onError);
  }

  Future<void> joinGroup(
      {required DocumentReference groupRef}) async {
    groupRef.update({C.numMembers: FieldValue.increment(1)});
    final result = await currUserRef.update({
      C.groups: FieldValue.arrayUnion([groupRef])
    });
    GroupsDatabaseService _tempGroups = GroupsDatabaseService(currUserRef: currUserRef);
    _tempGroups.updateGroupStats(groupRef: groupRef);
    return result;
  }

  Future<void> leaveGroup(
      {required DocumentReference userRef, required DocumentReference groupRef}) async {
    groupRef.update({C.numMembers: FieldValue.increment(-1)});
    return await userRef.update({
      C.groups: FieldValue.arrayRemove([groupRef])
    });
  }

  // get other users from userRef
  Future<UserData?> getUserData({required DocumentReference userRef, bool? noDomainData}) async {
    final snapshot = await userRef.get();
    return await _userDataFromSnapshot(snapshot, overrideUserRef: userRef, noDomainData: noDomainData);
  }

  // home data from snapshot
  Future<UserData?> _userDataFromSnapshot(DocumentSnapshot snapshot, {DocumentReference? overrideUserRef, bool? noDomainData}) async {
    if (snapshot.exists) {
      return await userDataFromSnapshot(snapshot, overrideUserRef != null ? overrideUserRef : currUserRef, noDomainData: noDomainData);
    } else {
      return null;
    }
  }

  // get home doc stream
  Stream<UserData?> get userData {
    return currUserRef.snapshots().asyncMap((event) => _userDataFromSnapshot(event));
  }

  SearchResult _streamResultFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    return SearchResult(
      resultRef: querySnapshot.reference,
      resultType: SearchResultType.people,
      resultDescription: querySnapshot[C.domain],
      resultText: querySnapshot[C.displayedName],
    );
  }

  Stream<List<SearchResult>> searchStream(String searchKey) {
    final searchKeyLC = searchKey.toLowerCase();
    return userDataCollection
        .where(C.displayedNameLC, isGreaterThanOrEqualTo: searchKeyLC)
        .where(C.displayedNameLC, isLessThan: searchKeyLC + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_streamResultFromQuerySnapshot).toList());
  }
}
