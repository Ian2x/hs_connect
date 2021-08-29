import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/known_domain.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/known_domains_database.dart';

class UserInfoDatabaseService {
  final String? userId;

  UserInfoDatabaseService({this.userId});

  // collection reference
  final CollectionReference userInfoCollection =
      FirebaseFirestore.instance.collection('userInfo');

  Future initUserData(String domain, String username) async {

    final GroupsDatabaseService _groupDatabaseService = GroupsDatabaseService();
    final KnownDomainsDatabaseService _knownDomainsDatabaseService = KnownDomainsDatabaseService();


    // Create domain group if not already created
    final docId = await _groupDatabaseService.newGroup(accessRestrictions: AccessRestriction(restrictionType: 'domain', restriction: domain), name: domain, userId: '');
    // Find domain info (county, state, country)
    final KnownDomain? kd = await _knownDomainsDatabaseService.getKnownDomain(domain: domain);
    print("kd below");
    print(await _knownDomainsDatabaseService.getKnownDomain(domain: domain));
    print(kd);
    if(kd!=null) {
      print(kd.county);
      print(kd.state);
      print(kd.country);
    }

    return await userInfoCollection.doc(userId).set({
      'displayedName': username,
      'domain': domain,
      'county': kd!=null ? kd.county : null,
      'state': kd!=null ? kd.state : null,
      'country': kd!=null ? kd.country : null,
      'userGroups': [UserGroup(groupId: docId, public: true).asMap()],
      'imageURL': '',
      'score': 0,
    });
  }

  Future updateProfile(
      {required String displayedName,
      required String imageURL,
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

  // get other users from userId
  Future getUserData({required String userId}) async {
    final snapshot = await userInfoCollection.doc(userId).get();
    return _userDataFromSnapshot(snapshot);
  }

  // home data from snapshot
  UserData? _userDataFromSnapshot(DocumentSnapshot snapshot) {

    if(snapshot.exists) {
      return UserData(
        userId: userId!,
        displayedName: snapshot.get('displayedName'),
        domain: snapshot.get('domain'),
        county: snapshot.get('county'),
        state: snapshot.get('state'),
        country: snapshot.get('country'),
        userGroups: snapshot.get('userGroups').map<UserGroup>((userGroup) => UserGroup(groupId: userGroup['groupId'], public: userGroup['public'])).toList(),
        imageURL: snapshot.get('imageURL'),
        score: snapshot.get('score'),
      );
    } else {
      return null;
    }
  }

  // get Users from list of userIds, must be wrapped in FutureBuilder to use
  Future<QuerySnapshot<Object?>> getUsers({required List<String> userIds}) async {
    return userInfoCollection.where(FieldPath.documentId, whereIn: userIds).get();
  }

  // get home doc stream
  Stream<UserData?> get userData {
    return userInfoCollection
        .doc(userId)
        .snapshots()
        .map(_userDataFromSnapshot);
  }
}
