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
    QuerySnapshot docs = await groupsCollection
        .where('name', isEqualTo: name)
        .where('accessRestrictions', isEqualTo: accessRestrictions.asMap())
        .get();
    if (docs.size > 0) {
      return docs.docs.first.id;
    } else {
      DocumentReference docRef = await groupsCollection.doc();
      final docId = docRef.id;
      await groupsCollection.doc(docId)
          .set({
            'accessRestrictions': accessRestrictions.asMap(),
            'name': name,
            'userId': userId,
            'image': image,
          })
          .then(onValue)
          .catchError(onError);
      return docId;
    }
  }

  // get group data from groupId
  Future<Group?> group({required String groupId}) async {
    await groupsCollection.doc(groupId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot.data();
      } else {
        return null;
      }
    });
  }

  // for converting userGroups to Groups, must be wrapped in FutureBuilder (see post_form for reference)
  Future<QuerySnapshot<Object?>> getGroups({required List<UserGroup> userGroups}) async {
    return groupsCollection.where(FieldPath.documentId, whereIn: userGroups.map((userGroup) {return userGroup.groupId;}).toList()).get();
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