import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/user_data.dart';

class UserInfoDatabaseService {
  final String? userId;

  UserInfoDatabaseService({this.userId});

  // collection reference
  final CollectionReference userInfoCollection =
      FirebaseFirestore.instance.collection('userInfo');

  Future initUserData(String domain, String username) async {
    return await userInfoCollection.doc(userId).set({
      'displayedName': username,
      'domain': domain,
      'county': '<county>',
      'state': '<state>',
      'country': '<country>',
      'groups': [],
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

  // get other use from userId
  Future getUserData({required String userId}) async {
    final snapshot = await userInfoCollection.doc(userId).get();
    return _userDataFromSnapshot(snapshot);
  }

  // user data from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      userId: userId!,
      displayedName: snapshot.get('displayedName'),
      domain: snapshot.get('domain'),
      county: snapshot.get('county'),
      state: snapshot.get('state'),
      country: snapshot.get('country'),
      groups: snapshot.get('groups'),
      //  as List<Group>,//  as <Group>[],//snapshot.get('groups'),
      imageURL: snapshot.get('imageURL'),
      score: snapshot.get('score'),
    );
  }

  // get user doc stream
  Stream<UserData> get userData {
    return userInfoCollection
        .doc(userId)
        .snapshots()
        .map(_userDataFromSnapshot);
  }
}
