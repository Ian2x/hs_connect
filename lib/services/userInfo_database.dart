import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/known_domain.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/known_domains_database.dart';

class UserInfoDatabaseService {
  final String? userId;
  DocumentReference? userRef;

  UserInfoDatabaseService({this.userId}) {
    setUserRef(userId);
  }

  void setUserRef(String? userId) async {
    if (userId!=null) {
      final temp = await userInfoCollection.doc(userId).get();
      this.userRef = temp.reference;
    }
  }

  // collection reference
  final CollectionReference userInfoCollection =
      FirebaseFirestore.instance.collection('userInfo');

  Future initUserData(String domain, String username) async {

    final GroupsDatabaseService _groupDatabaseService = GroupsDatabaseService();
    final KnownDomainsDatabaseService _knownDomainsDatabaseService = KnownDomainsDatabaseService();


    // Create domain group if not already created
    final docRef = await _groupDatabaseService.newGroup(accessRestrictions: AccessRestriction(restrictionType: 'domain', restriction: domain), name: domain, userRef: null);
    // Find domain info (county, state, country)
    final KnownDomain? kd = await _knownDomainsDatabaseService.getKnownDomain(domain: domain);

    return await userInfoCollection.doc(userId).set({
      'displayedName': username,
      'domain': domain,
      'county': kd!=null ? kd.county : null,
      'state': kd!=null ? kd.state : null,
      'country': kd!=null ? kd.country : null,
      'userGroups': [UserGroup(groupRef: docRef, public: true).asMap()],
      'imageURL': null,
      'score': 0,
    });
  }

  Future updateProfile(
      {required String displayedName,
      required String? imageURL,
      required Function(void) onValue,
      required Function onError}) async {
      return await userInfoCollection
          .doc(userId)
          .update({
        'displayedName': displayedName,
        'imageURL': imageURL,
      })
          .then(onValue)
          .catchError(onError);
  }

  Future joinGroup({required DocumentReference userRef, required DocumentReference groupRef, required bool public}) async {
    return await userRef.update({'userGroups': FieldValue.arrayUnion([{'groupRef': groupRef, 'public': public}])});
  }

  // get other users from userRef
  Future getUserData({required DocumentReference userRef}) async {
    final snapshot = await userRef.get();
    return _userDataFromSnapshot(snapshot, overrideUserRef: userRef);
  }

  // home data from snapshot
  UserData? _userDataFromSnapshot(DocumentSnapshot snapshot, {DocumentReference? overrideUserRef}) {
    if(snapshot.exists) {

      return UserData(
        userRef: overrideUserRef!=null ? overrideUserRef : userRef!,
        displayedName: snapshot.get('displayedName'),
        domain: snapshot.get('domain'),
        county: snapshot.get('county'),
        state: snapshot.get('state'),
        country: snapshot.get('country'),
        userGroups: snapshot.get('userGroups').map<UserGroup>((userGroup) => UserGroup(groupRef: userGroup['groupRef'], public: userGroup['public'])).toList(),
        image: snapshot.get('imageURL'),
        score: snapshot.get('score'),
      );
    } else {
      return null;
    }
  }

  // get Users from list of userRefs, must be wrapped in FutureBuilder to use
  Future<QuerySnapshot<Object?>> getUsers({required List<DocumentReference> userRefs}) async {
    return userInfoCollection.where(FieldPath.documentId, whereIn: userRefs.map((userRef) {return userRef.id;}).toList()).get();
  }

  // get home doc stream
  Stream<UserData?> get userData {
    return userInfoCollection
        .doc(userId)
        .snapshots()
        .map(_userDataFromSnapshot);
  }
}
