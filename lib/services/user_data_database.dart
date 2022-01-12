import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/knownDomain.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/known_domains_database.dart';
import 'package:hs_connect/shared/constants.dart';

class UserDataDatabaseService {
  DocumentReference currUserRef;

  UserDataDatabaseService({required this.currUserRef});

  // collection reference
  final CollectionReference userDataCollection = FirebaseFirestore.instance.collection(C.userData);

  Future<void> initUserData(String domain, String username) async {
    final GroupsDatabaseService _groupDatabaseService = GroupsDatabaseService(currUserRef: currUserRef);
    final KnownDomainsDatabaseService _knownDomainsDatabaseService = KnownDomainsDatabaseService();

    // Create domain group if not already created
    final docRef = await _groupDatabaseService.newGroup(
        accessRestriction: AccessRestriction(restrictionType: AccessRestrictionType.domain, restriction: domain),
        name: domain,
        creatorRef: null,
        image: null,
        description: 'Default group for ' + domain);
    // Find domain data (county, state, country)
    final KnownDomain? kd = await _knownDomainsDatabaseService.getKnownDomain(domain: domain);
    return await currUserRef.set({
      C.displayedName: username,
      C.displayedNameLC: username.toLowerCase(),
      C.bio: null,
      C.domain: domain,
      C.county: kd != null ? kd.county : null,
      C.state: kd != null ? kd.state : null,
      C.country: kd != null ? kd.country : null,
      C.userGroups: [UserGroup(groupRef: docRef, public: true).asMap()],
      C.modGroupRefs: [],
      C.messagesRefs: [],
      C.myPostsObservedRefs: [],
      C.myCommentsObservedRefs: [],
      C.myRepliesRefs: [],
      C.savedPostsRefs: [],
      C.profileImage: null,
      C.score: 0,
      C.reportsRefs: [],
    });
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
          C.profileImage: imageURL,
        })
        .then(onValue)
        .catchError(onError);
  }

  Future<void> joinGroup(
      {required DocumentReference groupRef, required bool public}) async {
    groupRef.update({C.numMembers: FieldValue.increment(1)});
    final result = await currUserRef.update({
      C.userGroups: FieldValue.arrayUnion([
        {C.groupRef: groupRef, C.public: public}
      ])
    });
    GroupsDatabaseService _tempGroups = GroupsDatabaseService(currUserRef: currUserRef);
    _tempGroups.updateGroupStats(groupRef: groupRef);
    return result;
  }

  Future<void> leaveGroup(
      {required DocumentReference userRef, required DocumentReference groupRef, required bool public}) async {
    groupRef.update({C.numMembers: FieldValue.increment(-1)});
    return await userRef.update({
      C.userGroups: FieldValue.arrayRemove([
        {C.groupRef: groupRef, C.public: public}
      ])
    });
  }

  // get other users from userRef
  Future<UserData?> getUserData({required DocumentReference userRef}) async {
    final snapshot = await userRef.get();
    return _userDataFromSnapshot(snapshot, overrideUserRef: userRef);
  }

  // home data from snapshot
  UserData? _userDataFromSnapshot(DocumentSnapshot snapshot, {DocumentReference? overrideUserRef}) {
    if (snapshot.exists) {
      return userDataFromSnapshot(snapshot, overrideUserRef != null ? overrideUserRef : currUserRef);
    } else {
      return null;
    }
  }

  // get home doc stream
  Stream<UserData?> get userData {
    return currUserRef.snapshots().map(_userDataFromSnapshot);
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
