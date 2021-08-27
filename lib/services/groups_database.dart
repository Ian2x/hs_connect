import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/user_data.dart';

void defaultFunc (dynamic parameter) {}

class GroupsDatabaseService {
  final String? userId;

  GroupsDatabaseService({this.userId});

  // collection reference
  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection('groups');

  Future newGroup(
      {required AccessRestrictions accessRestrictions,
      required String name,
      required String userId,
      String? image = '',
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    print('in group database file');
    QuerySnapshot document = await groupsCollection
        .where('name', isEqualTo: name)
        .where('accessRestrictions', isEqualTo: accessRestrictions.asMap())
        .get();
    if (document.size > 0) {
      return 'Group already exists';
    } else {
      return await groupsCollection
          .add({
            'accessRestrictions': accessRestrictions.asMap(),
            'name': name,
            'userId': userId,
            'image': image,
          })
          .then(onValue)
          .catchError(onError);
    }
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
        userGroups: snapshot.get('groups'),
        //  as List<Group>,//  as <Group>[],//snapshot.get('groups'),
        imageURL: snapshot.get('imageURL'),
        score: snapshot.get('score'),
      );
    } else {
      return null;
    }
  }

  // get home doc stream
  Stream<UserData?> get userData {
    return groupsCollection
        .doc(userId)
        .snapshots()
        .map(_userDataFromSnapshot);
  }
}


/*

class AccessRestrictions {
  final String? domain;
  final String? county;
  final String? state;
  final String? country;

  AccessRestrictions({
    required this.domain,
    required this.county,
    required this.state,
    required this.country,
  });
}

class Group {
  final String groupId;
  final String userId;
  String name;
  String? image;
  final AccessRestrictions accessRestrictions;

  Group({
    required this.groupId,
    required this.userId,
    required this.name,
    required this.image,
    required this.accessRestrictions,
  });
}

 */