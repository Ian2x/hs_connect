import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';


void defaultFunc(dynamic parameter) {}

class PostsDatabaseService {
  final DocumentReference? userRef;
  List<DocumentReference>? groupRefs;
  List<String>? searchTags;

  PostsDatabaseService({this.userRef, this.groupRefs, this.searchTags});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

  Future<DocumentReference> newPost({required String title, required String text,
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
      'reports': [],
      'tags': tags,
    })
        .then(onValue)
        .catchError(onError);
  }

  Future<dynamic> deletePost(
      {required DocumentReference postRef, required DocumentReference groupRef, required DocumentReference userRef, String? media}) async {
    final checkAuth = await postRef.get();
    if (checkAuth.exists) {
      if (userRef == checkAuth.get('userRef')) {
        groupRef.update({'numPosts': FieldValue.increment(-1)});

        // delete post's comments
        final delComments = FirebaseFirestore.instance.collection('comments').get().then((snapshot) async {
          List<DocumentSnapshot> allDocs = snapshot.docs;
          List<DocumentSnapshot> filteredDocs = await allDocs.where(
                  (document) => document.get('postRef') == postRef
          ).toList();
          for (DocumentSnapshot ds in filteredDocs) {
            ds.reference.delete();
          }
        });

        // delete post's replies
        final delReplies = FirebaseFirestore.instance.collection('replies').get().then((snapshot) async {
          List<DocumentSnapshot> allDocs = snapshot.docs;
          List<DocumentSnapshot> filteredDocs = await allDocs.where(
                  (document) => document.get('postRef') == postRef
          ).toList();
          for (DocumentSnapshot ds in filteredDocs) {
            ds.reference.delete();
          }
        });

        // delete post
        final delPost = postRef.delete();
        await delComments;
        await delReplies;
        await delPost;
        // delete image
        if (media != null) {
          return await _images.deleteImage(imageURL: media);
        }
      };
    }
    return null;
  }


  Future<void> likePost({required DocumentReference postRef, required DocumentReference userRef}) async {
    // remove dislike if disliked
    await postRef.update({'dislikes': FieldValue.arrayRemove([userRef])});
    // like comment
    return await postRef.update({'likes': FieldValue.arrayUnion([userRef])});
  }

  Future<void> unLikePost({required DocumentReference postRef, required DocumentReference userRef}) async {
    // remove like
    await postRef.update({'likes': FieldValue.arrayRemove([userRef])});
  }

  Future<void> dislikePost({required DocumentReference postRef, required DocumentReference userRef}) async {
    // remove like if liked
    await postRef.update({'likes': FieldValue.arrayRemove([userRef])});
    // dislike comment
    return await postRef.update({'dislikes': FieldValue.arrayUnion([userRef])});
  }

  Future<void> unDislikePost({required DocumentReference postRef, required DocumentReference userRef}) async {
    // remove like
    await postRef.update({'dislikes': FieldValue.arrayRemove([userRef])});
  }


  // home data from snapshot
  Post? _postFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    if (querySnapshot.exists) {
      print("a");
      final temp = Post(
        postRef: querySnapshot.reference,
        userRef: querySnapshot['userRef'],
        groupRef: querySnapshot['groupRef'],
        media: querySnapshot['media'],
        title: querySnapshot['title'],
        text: querySnapshot['text'],
        createdAt: querySnapshot['createdAt'],
        numComments: querySnapshot['numComments'],
        likes: (querySnapshot['likes'] as List).map((item) => item as DocumentReference).toList(),
        dislikes: (querySnapshot['dislikes'] as List).map((item) => item as DocumentReference).toList(),
        reports: (querySnapshot['reports'] as List).map((item) => item as DocumentReference).toList(),
        tags: (querySnapshot['tags'] as List).map((item) => item as String).toList(),
      );
      print("b");
      return temp;
    } else {
      return null;
    }
  }

  Stream<List<Post?>> get posts {
    return postsCollection
        .where('groupRef', whereIn: groupRefs)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_postFromQuerySnapshot).toList());
  }

  Future<List<Post?>> getMultiGroupPosts() async {
    final snapshot = await postsCollection.where('groupRef', whereIn: groupRefs).get();
    return snapshot.docs.map(_postFromQuerySnapshot).toList();
  }

  Stream<List<Post?>> get potentialTrendingPosts {
    return postsCollection
        .where(
        'createdAt', isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(new Duration(days: daysTrending))))
        .where('groupRef', whereIn: groupRefs)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_postFromQuerySnapshot).toList());
  }

  Stream<List<Post?>> get tagPosts {
    return postsCollection
        .where('tags', arrayContainsAny: searchTags)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_postFromQuerySnapshot).toList());
  }

}
