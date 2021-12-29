import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:provider/provider.dart';


void defaultFunc(dynamic parameter) {}

class CommentsDatabaseService {
  final DocumentReference? userRef;

  DocumentReference? postRef;

  CommentsDatabaseService({this.userRef, this.postRef});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference commentsCollection = FirebaseFirestore.instance.collection('comments');

  Future<DocumentReference> newComment({required String text,
    required String? mediaURL,
    required DocumentReference postRef,
    Function(void) onValue = defaultFunc,
    Function onError = defaultFunc}) async {

    postRef.update({'numComments': FieldValue.increment(1)});

    return await commentsCollection
        .add({
      'userRef': userRef,
      'postRef': postRef,
      'text': text,
      'media': mediaURL,
      'createdAt': DateTime.now(),
      'numReplies': 0,
      'likes': List<String>.empty(),
      'dislikes': List<String>.empty(),
      'reports': [],
    })
        .then(onValue)
        .catchError(onError);
  }

  Future<dynamic> deleteComment({required DocumentReference commentRef, required DocumentReference postRef, required DocumentReference userRef, String? media}) async {
    final checkAuth = await commentRef.get();
    if(checkAuth.exists) {
      if (userRef==checkAuth.get('userRef')) {

        postRef.update({'numComments': FieldValue.increment(-1)});

        await commentRef.update({'likes': [], 'dislikes': [], 'media': null, 'userRef': null, 'text': '[Comment removed]'});

        if (media!=null) {
          return await _images.deleteImage(imageURL: media);
        }
      };
    }
    return null;
  }

  Future<void> likeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove dislike if disliked
    await commentRef.update({'dislikes': FieldValue.arrayRemove([userRef])});
    // like comment
    return await commentRef.update({'likes': FieldValue.arrayUnion([userRef])});
  }

  Future<void> unLikeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove like
    await commentRef.update({'likes': FieldValue.arrayRemove([userRef])});
  }

  Future<void> dislikeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove like if liked
    await commentRef.update({'likes': FieldValue.arrayRemove([userRef])});
    // dislike comment
    return await commentRef.update({'dislikes': FieldValue.arrayUnion([userRef])});
  }

  Future<void> unDislikeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove like
    await commentRef.update({'dislikes': FieldValue.arrayRemove([userRef])});
  }

  // home data from snapshot
  Comment? _commentFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    if (querySnapshot.exists) {
      return Comment(
        commentRef: querySnapshot.reference,
        postRef: querySnapshot['postRef'],
        userRef: querySnapshot['userRef'],
        text: querySnapshot['text'],
        media: querySnapshot['media'],
        createdAt: querySnapshot['createdAt'],
        numReplies: querySnapshot['numReplies'],
        likes: (querySnapshot['likes'] as List).map((item) => item as DocumentReference).toList(),
        dislikes: (querySnapshot['dislikes'] as List).map((item) => item as DocumentReference).toList(),
        reports: (querySnapshot['reports'] as List).map((item) => item as DocumentReference).toList(),
      );
    } else {
      return null;
    }
  }

  Stream<List<Comment?>> get postComments {
    return commentsCollection.where('postRef', isEqualTo: postRef).orderBy('createdAt', descending: false).snapshots().map((snapshot) => snapshot.docs.map(_commentFromQuerySnapshot).toList());
  }

}
