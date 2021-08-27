import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/user_data.dart';

void defaultFunc (dynamic parameter) {}

class PostsDatabaseService {
  final String? userId;

  PostsDatabaseService({this.userId});

  // collection reference
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');


  Future newPost(
      {required String text,
      required String? imageURL,
      required String groupId,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    return await postsCollection
        .add({
          'userId': userId,
          'groupId': groupId,
          'text': text,
          'image': imageURL == null || imageURL == '' ? '' : imageURL,
          'createdAt': DateTime.now(),
          'likes': List<String>.empty(),
          'dislikes': List<String>.empty(),
        })
        .then(onValue)
        .catchError(onError);
  }

  // get other use from userId
  Future getUserData({required String userId}) async {
    final snapshot = await postsCollection.doc(userId).get();
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
    return postsCollection
        .doc(userId)
        .snapshots()
        .map(_userDataFromSnapshot);
  }
}
