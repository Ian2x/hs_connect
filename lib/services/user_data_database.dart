import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/knownDomain.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/known_domains_database.dart';
import 'package:hs_connect/shared/constants.dart';

class UserDataDatabaseService {
  DocumentReference? userRef;

  UserDataDatabaseService({this.userRef});

  // collection reference
  final CollectionReference userDataCollection = FirebaseFirestore.instance.collection(C.userData);

  Future<void> initUserData(String domain, String username) async {
    final GroupsDatabaseService _groupDatabaseService = GroupsDatabaseService();
    final KnownDomainsDatabaseService _knownDomainsDatabaseService = KnownDomainsDatabaseService();

    // Create domain group if not already created
    final docRef = await _groupDatabaseService.newGroup(
        accessRestriction: AccessRestriction(restrictionType: AccessRestrictionType.domain, restriction: domain),
        name: domain,
        creatorRef: null,
        image: null,
        description: null);
    // Find domain data (county, state, country)
    final KnownDomain? kd = await _knownDomainsDatabaseService.getKnownDomain(domain: domain);
    return await userRef!.set({
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
      C.postsRefs: [],
      C.commentsRefs: [],
      C.repliesRefs: [],
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
    return await userRef!
        .update({
          C.displayedName: displayedName,
          C.displayedNameLC: displayedName.toLowerCase(),
          C.profileImage: imageURL,
        })
        .then(onValue)
        .catchError(onError);
  }

  Future<void> joinGroup(
      {required DocumentReference userRef, required DocumentReference groupRef, required bool public}) async {
    groupRef.update({C.numMembers: FieldValue.increment(1)});
    return await userRef.update({
      C.userGroups: FieldValue.arrayUnion([
        {C.groupRef: groupRef, C.public: public}
      ])
    });
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
      return UserData.fromSnapshot(snapshot, overrideUserRef != null ? overrideUserRef : userRef!);
    } else {
      return null;
    }
  }

  // get Users from list of userRefs, should be wrapped in FutureBuilder to use
  Future<QuerySnapshot> getUsers({required List<DocumentReference> userRefs}) async {
    return userDataCollection
        .where(FieldPath.documentId,
            whereIn: userRefs.map((userRef) {
              return userRef.id;
            }).toList())
        .get();
  }

  // get home doc stream
  Stream<UserData?>? get userData {
    if (userRef != null) {
      return userRef!.snapshots().map(_userDataFromSnapshot);
    } else {
      return null;
    }
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
    final LCsearchKey = searchKey.toLowerCase();
    return userDataCollection
        .where(C.displayedNameLC, isGreaterThanOrEqualTo: LCsearchKey)
        .where(C.displayedNameLC, isLessThan: LCsearchKey + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_streamResultFromQuerySnapshot).toList());
  }
}
