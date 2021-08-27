import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/groups_database.dart';

class UserInfoDatabaseService {
  final String? userId;

  UserInfoDatabaseService({this.userId});

  // collection reference
  final CollectionReference userInfoCollection =
      FirebaseFirestore.instance.collection('userInfo');

  Future initUserData(String domain, String username) async {

    final GroupsDatabaseService _groupDatabaseService = GroupsDatabaseService();

    await _groupDatabaseService.newGroup(accessRestrictions: AccessRestrictions(domain: domain, county: null, state: null, country: null), name: domain, userId: '');

    return await userInfoCollection.doc(userId).set({
      'displayedName': username,
      'domain': domain,
      'county': '<county>',
      'state': '<state>',
      'country': '<country>',
      'userGroups': [UserGroup(userGroup: domain, public: true).asMap()],
      'imageURL': '<imageURL>',
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
        userGroups: snapshot.get('userGroups').map<UserGroup>((userGroup) => UserGroup(userGroup: userGroup['userGroup'], public: userGroup['public'])).toList(),
        imageURL: snapshot.get('imageURL'),
        score: snapshot.get('score'),
      );
    } else {
      return null;
    }
  }

  // get home doc stream
  Stream<UserData?> get userData {
    return userInfoCollection
        .doc(userId)
        .snapshots()
        .map(_userDataFromSnapshot);
  }
}
