import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';

void defaultFunc(dynamic parameter) {}

class CommentsDatabaseService {
  final DocumentReference? userRef;

  DocumentReference? postRef;

  CommentsDatabaseService({this.userRef, this.postRef});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference commentsCollection = FirebaseFirestore.instance.collection('comments');

  Future newComment(
      {required String text,
      required String? mediaURL,
      required DocumentReference postRef,
      required DocumentReference groupRef,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    postRef.update({C.numComments: FieldValue.increment(1)});
    final group = await groupRef.get();
    final accessRestriction = group.get(C.accessRestriction);

    return await commentsCollection
        .add({
          C.postRef: postRef,
          C.groupRef: groupRef,
          C.creatorRef: userRef,
          C.text: text,
          C.media: mediaURL,
          C.createdAt: DateTime.now(),
          C.numReplies: 0,
          C.accessRestriction: accessRestriction,
          C.likes: [],
          C.dislikes: [],
          C.reportsRefs: [],
        })
        .then(onValue)
        .catchError(onError);
  }

  Future<dynamic> deleteComment(
      {required DocumentReference commentRef,
      required DocumentReference postRef,
      required DocumentReference userRef,
      String? media}) async {
    final checkAuth = await commentRef.get();
    if (checkAuth.exists) {
      if (userRef == checkAuth.get(C.creatorRef)) {
        postRef.update({C.numComments: FieldValue.increment(-1)});

        await commentRef
            .update({C.likes: [], C.dislikes: [], C.media: null, C.creatorRef: null, C.text: '[Comment removed]'});

        if (media != null) {
          return await _images.deleteImage(imageURL: media);
        }
      }
      ;
    }
    return null;
  }

  Future<void> likeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove dislike if disliked
    await commentRef.update({
      C.dislikes: FieldValue.arrayRemove([userRef])
    });
    // like comment
    return await commentRef.update({
      C.likes: FieldValue.arrayUnion([userRef])
    });
  }

  Future<void> unLikeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove like
    await commentRef.update({
      C.likes: FieldValue.arrayRemove([userRef])
    });
  }

  Future<void> dislikeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove like if liked
    await commentRef.update({
      C.likes: FieldValue.arrayRemove([userRef])
    });
    // dislike comment
    return await commentRef.update({
      C.dislikes: FieldValue.arrayUnion([userRef])
    });
  }

  Future<void> unDislikeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove like
    await commentRef.update({
      C.dislikes: FieldValue.arrayRemove([userRef])
    });
  }

  // home data from snapshot
  Comment? _commentFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    if (querySnapshot.exists) {
      return Comment.fromQuerySnapshot(querySnapshot);
    } else {
      return null;
    }
  }

  Stream<List<Comment?>> get postComments {
    return commentsCollection
        .where(C.postRef, isEqualTo: postRef)
        .orderBy(C.createdAt, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_commentFromQuerySnapshot).toList());
  }
}
