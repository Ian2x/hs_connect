import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/known_domain.dart';
import 'package:hs_connect/models/message.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/known_domains_database.dart';

class UserDataDatabaseService {
  DocumentReference? userRef;

  UserDataDatabaseService({this.userRef}) {
  }

  // collection reference
  final CollectionReference userDataCollection =
      FirebaseFirestore.instance.collection('userData');

  Future<void> initUserData(String domain, String username) async {

    final GroupsDatabaseService _groupDatabaseService = GroupsDatabaseService();
    final KnownDomainsDatabaseService _knownDomainsDatabaseService = KnownDomainsDatabaseService();


    // Create domain group if not already created
    final docRef = await _groupDatabaseService.newGroup(accessRestrictions: AccessRestriction(restrictionType: 'domain', restriction: domain), name: domain, creatorRef: null, image: null, description: null);
    // Find domain data (county, state, country)
    final KnownDomain? kd = await _knownDomainsDatabaseService.getKnownDomain(domain: domain);

    return await userRef!.set({
      'displayedName': username,
      'LCdisplayedName': username.toLowerCase(),
      'domain': domain,
      'county': kd!=null ? kd.county : null,
      'state': kd!=null ? kd.state : null,
      'country': kd!=null ? kd.country : null,
      'userGroups': [UserGroup(groupRef: docRef, public: true).asMap()],
      'messages': [],
      'imageURL': null,
      'score': 0,
      'warnings': 0,
    });
  }

  Future<void> updateProfile(
      {required String displayedName,
      required String? imageURL,
      required Function(void) onValue,
      required Function onError}) async {
      return await userRef!
          .update({
        'displayedName': displayedName,
        'LCdisplayedName': displayedName.toLowerCase(),
        'imageURL': imageURL,
      })
          .then(onValue)
          .catchError(onError);
  }

  Future<void> joinGroup({required DocumentReference userRef, required DocumentReference groupRef, required bool public}) async {
    groupRef.update({'numMembers': FieldValue.increment(1)});
    return await userRef.update({'userGroups': FieldValue.arrayUnion([{'groupRef': groupRef, 'public': public}])});
  }

  Future<void> leaveGroup({required DocumentReference userRef, required DocumentReference groupRef, required bool public}) async {
    groupRef.update({'numMembers': FieldValue.increment(-1)});
    return await userRef.update({'userGroups': FieldValue.arrayRemove([{'groupRef': groupRef, 'public': public}])});
  }

  // get other users from userRef
  Future<UserData?> getUserData({required DocumentReference userRef}) async {
    final snapshot = await userRef.get();
    return _userDataFromSnapshot(snapshot, overrideUserRef: userRef);
  }

  // home data from snapshot
  UserData? _userDataFromSnapshot(DocumentSnapshot snapshot, {DocumentReference? overrideUserRef}) {
    if (snapshot.exists) {
      final temp = UserData(
        userRef: overrideUserRef != null ? overrideUserRef : userRef!,
        displayedName: snapshot.get('displayedName'),
        LCdisplayedName: snapshot.get('displayedName'),
        domain: snapshot.get('domain'),
        county: snapshot.get('county'),
        state: snapshot.get('state'),
        country: snapshot.get('country'),
        userGroups: snapshot
            .get('userGroups')
            .map<UserGroup>((userGroup) => UserGroup(groupRef: userGroup['groupRef'], public: userGroup['public']))
            .toList(),
        messages: snapshot
            .get('messages')
            .map<Message>((message) => Message(
                messageRef: message['messageRef'],
                senderRef: message['sender'],
                receiverRef: message['receiver'],
                text: message['text'],
                createdAt: message['createdAt'],
                isMedia: message['isMedia'],
                reportedStatus: message['reportedStatus']))
            .toList(),
        image: snapshot.get('imageURL'),
        score: snapshot.get('score'),
        warnings: snapshot.get('warnings'),
      );
      return temp;
    } else {
      return null;
    }
  }

  // get Users from list of userRefs, must be wrapped in FutureBuilder to use
  Future<QuerySnapshot> getUsers({required List<DocumentReference> userRefs}) async {
    return userDataCollection.where(FieldPath.documentId, whereIn: userRefs.map((userRef) {return userRef.id;}).toList()).get();
  }

  // get home doc stream
  Stream<UserData?>? get userData {
    if(userRef!=null) {
      return userRef!
          .snapshots()
          .map(_userDataFromSnapshot);
    } else {
      return null;
    }
  }
}
