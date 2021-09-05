import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/services/comments_database.dart';


void defaultFunc(dynamic parameter) {}

class PostsDatabaseService {
  final String? userId;

  String? groupId;
  List<String>? groupsId;

  PostsDatabaseService({this.userId, this.groupId, this.groupsId});

  void setGroupId({required String groupId}) {
    this.groupId = groupId;
  }

  // collection reference
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

  Future newPost({required String title, required String text,
    required String? imageURL,
    required String groupId,
    Function(void) onValue = defaultFunc,
    Function onError = defaultFunc}) async {
    return await postsCollection
        .add({
      'userId': userId,
      'groupId': groupId,
      'title': title,
      'text': text,
      'image': imageURL == null || imageURL == '' ? '' : imageURL,
      'createdAt': DateTime.now(),
      'likes': List<String>.empty(),
      'dislikes': List<String>.empty(),
    })
        .then(onValue)
        .catchError(onError);
  }

  Future deletePost({required String postId, required String userId}) async {
    final checkAuth = await postsCollection.doc(postId).get();
    if(checkAuth.exists) {
      if (userId==checkAuth.get('userId')) {
        // delete post's comments

        await FirebaseFirestore.instance.collection('comments').get().then((snapshot) async {
          List<DocumentSnapshot> allDocs = snapshot.docs;
          List<DocumentSnapshot> filteredDocs = await allDocs.where(
                  (document) => document.get('postId') == postId
          ).toList();
          for (DocumentSnapshot ds in filteredDocs){
            await ds.reference.delete();
          }
        });


        // delete post
        return await postsCollection.doc(postId).delete();
      };
    }
    return null;
  }


  // home data from snapshot
  Post? _postFromDocument(QueryDocumentSnapshot document) {
    if (document.exists) {
      return Post(
        postId: document.id,
        userId: document['userId'],
        groupId: document['groupId'],
        image: document['image'],
        title: document['title'],
        text: document['text'],
        createdAt: document['createdAt'],//.toString(),
        likes: (document['likes'] as List).map((item) => item as String).toList(),
        dislikes: (document['dislikes'] as List).map((item) => item as String).toList(),//document['dislikes'],
      );
    } else {
      return null;
    }
  }

  Stream<List<Post?>> get singleGroupPosts {
    return postsCollection.where('groupId', isEqualTo: groupId).orderBy('createdAt', descending: false).snapshots().map((snapshot) => snapshot.docs.map(_postFromDocument).toList());
  }

  Stream<List<Post?>> get multiGroupPosts {
    return postsCollection.where('groupId', whereIn: groupsId).orderBy('createdAt', descending: false).snapshots().map((snapshot) => snapshot.docs.map(_postFromDocument).toList());
  }

  Future getMultiGroupPosts() async {

    final snapshot = await postsCollection.where('groupId', whereIn: groupsId).get();
    return snapshot.docs.map(_postFromDocument).toList();
  }

}
