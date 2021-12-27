import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/services/storage/image_storage.dart';


void defaultFunc(dynamic parameter) {}

class PostsDatabaseService {
  final DocumentReference? userRef;

  DocumentReference? groupRef;
  List<DocumentReference>? groupsRefs;

  PostsDatabaseService({this.userRef, this.groupRef, this.groupsRefs});

  ImageStorage _images = ImageStorage();

  void setGroupRef({required DocumentReference groupRef}) {
    this.groupRef = groupRef;
  }

  // collection reference
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

  Future newPost({required String title, required String text,
    required String? mediaURL,
    required DocumentReference groupRef,
    required List<String> tags,
    Function(void) onValue = defaultFunc,
    Function onError = defaultFunc}) async {

    groupRef.update({'numPosts': FieldValue.increment(1)});

    return await postsCollection
        .add({
      'userRef': userRef,
      'groupRef': groupRef,
      'title': title,
      'text': text,
      'media': mediaURL,
      'createdAt': DateTime.now(),
      'numComments': 0,
      'likes': List<String>.empty(),
      'dislikes': List<String>.empty(),
      'reportedStatus': null,
      'tags': tags,
    })
        .then(onValue)
        .catchError(onError);
  }

  Future deletePost({required DocumentReference postRef, required DocumentReference groupRef, required DocumentReference userRef, String? media}) async {
    final checkAuth = await postRef.get();
    if(checkAuth.exists) {
      if (userRef==checkAuth.get('userRef')) {

        groupRef.update({'numPosts': FieldValue.increment(-1)});

        // delete post's comments
        await FirebaseFirestore.instance.collection('comments').get().then((snapshot) async {
          List<DocumentSnapshot> allDocs = snapshot.docs;
          List<DocumentSnapshot> filteredDocs = await allDocs.where(
                  (document) => document.get('postRef') == postRef
          ).toList();
          for (DocumentSnapshot ds in filteredDocs){
            await ds.reference.delete();
          }
        });

        // delete post's replies
        await FirebaseFirestore.instance.collection('replies').get().then((snapshot) async {
          List<DocumentSnapshot> allDocs = snapshot.docs;
          List<DocumentSnapshot> filteredDocs = await allDocs.where(
                  (document) => document.get('postRef') == postRef
          ).toList();
          for (DocumentSnapshot ds in filteredDocs){
            await ds.reference.delete();
          }
        });

        // delete post
        await postRef.delete();

        // delete image
        if (media!=null) {
          return await _images.deleteImage(imageURL: media);
        }
      };
    }
    return null;
  }



  Future likePost({required DocumentReference postRef, required DocumentReference userRef}) async {
    // remove dislike if disliked
    await postRef.update({'dislikes': FieldValue.arrayRemove([userRef])});
    // like comment
    return await postRef.update({'likes': FieldValue.arrayUnion([userRef])});
  }

  Future unLikePost({required DocumentReference postRef, required DocumentReference userRef}) async {
    // remove like
    await postRef.update({'likes': FieldValue.arrayRemove([userRef])});
  }

  Future dislikePost({required DocumentReference postRef, required DocumentReference userRef}) async {
    // remove like if liked
    await postRef.update({'likes': FieldValue.arrayRemove([userRef])});
    // dislike comment
    return await postRef.update({'dislikes': FieldValue.arrayUnion([userRef])});
  }

  Future unDislikePost({required DocumentReference postRef, required DocumentReference userRef}) async {
    // remove like
    await postRef.update({'dislikes': FieldValue.arrayRemove([userRef])});
  }



  // home data from snapshot
  Post? _postFromDocument(QueryDocumentSnapshot document) {
    if (document.exists) {
      return Post(
        postRef: document.reference,
        userRef: document['userRef'],
        groupRef: document['groupRef'],
        media: document['media'],
        title: document['title'],
        text: document['text'],
        createdAt: document['createdAt'],
        numComments: document['numComments'],
        likes: (document['likes'] as List).map((item) => item as DocumentReference).toList(),
        dislikes: (document['dislikes'] as List).map((item) => item as DocumentReference).toList(),
        reportedStatus: document['reportedStatus'],
        tags: document['tags'],
      );
    } else {
      return null;
    }
  }

  Stream<List<Post?>> get singleGroupPosts {
    return postsCollection.where('groupRef', isEqualTo: groupRef).orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map(_postFromDocument).toList());
  }

  Stream<List<Post?>> get multiGroupPosts {
    return postsCollection.where('groupRef', whereIn: groupsRefs).orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map(_postFromDocument).toList());
  }

  Future getMultiGroupPosts() async {

    final snapshot = await postsCollection.where('groupRef', whereIn: groupsRefs).get();
    return snapshot.docs.map(_postFromDocument).toList();
  }

}
