import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/post.dart';


void defaultFunc(dynamic parameter) {}

class PostsDatabaseService {
  final String? userId;

  String? groupId;

  PostsDatabaseService({this.userId, this.groupId});

  void setGroupId({required String groupId}) {
    this.groupId = groupId;
  }

  // collection reference
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

  Future newPost({required String text,
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

  // home data from snapshot
  Post? _postFromDocument(QueryDocumentSnapshot document) {
    if (document.exists) {
      print("IN STREAM {");
      print(document.id);
      print(document['createdAt'].toString());
      print((document['likes'] as List).map((item) => item as String).toList());
      // print(document['likes'] as List<String>);
      // (map['categories'] as List)?.map((item) => item as String)?.toList();
      final temp = Post(
        postId: document.id,
        userId: document['userId'],
        groupId: document['groupId'],
        image: document['image'],
        text: document['text'],
        createdAt: document['createdAt'].toString(),
        likes: (document['likes'] as List).map((item) => item as String).toList(),
        dislikes: (document['dislikes'] as List).map((item) => item as String).toList(),//document['dislikes'],
      );
      print(temp);
      print("} OUT STREAM");
      return temp;
    } else {
      return null;
    }
  }

  Stream<List<Post?>> get groupPosts {
    return postsCollection.where('groupId', isEqualTo: groupId).snapshots().map((snapshot) => snapshot.docs.map(_postFromDocument).toList());
  }
/*
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
   */
}
