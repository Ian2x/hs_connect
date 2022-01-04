import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';

void defaultFunc(dynamic parameter) {}

class CommentsDatabaseService {
  final DocumentReference userRef;
  final DocumentReference? postRef;
  final DocumentReference? commentRef;

  CommentsDatabaseService({required this.userRef, this.postRef, this.commentRef});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference commentsCollection = FirebaseFirestore.instance.collection(C.comments);

  Future newComment(
      {required String text,
      required String? media,
      required DocumentReference postRef,
      required DocumentReference groupRef,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    // get accessRestriction
    final group = await groupRef.get();
    final accessRestriction = group.get(C.accessRestriction);
    // update post's numComments
    postRef.update({C.numComments: FieldValue.increment(1)});
    // update user's comments
    DocumentReference commentRef = commentsCollection.doc();
    userRef.update({C.myCommentsRefs: FieldValue.arrayUnion([commentRef])});

    await commentRef
        .set({
          C.postRef: postRef,
          C.groupRef: groupRef,
          C.creatorRef: userRef,
          C.text: text,
          C.media: media,
          C.createdAt: DateTime.now(),
          C.numReplies: 0,
          C.accessRestriction: accessRestriction,
          C.likes: [],
          C.dislikes: [],
          C.reportsRefs: [],
        })
        .then(onValue)
        .catchError(onError);
    return commentRef;
  }

  Future<dynamic> deleteComment(
      {required DocumentReference commentRef,
      required DocumentReference postRef,
      String? media}) async {
    // check comment exists and matches current user
    final comment = await commentRef.get();
    if (comment.exists) {
      if (userRef == comment.get(C.creatorRef)) {
        // update post's numComments
        postRef.update({C.numComments: FieldValue.increment(-1)});
        // update user's comments
        userRef.update({C.myCommentsRefs: FieldValue.arrayRemove([commentRef])});
        // "delete" comment
        await commentRef
            .update({C.likes: [], C.dislikes: [], C.media: null, C.creatorRef: null, C.text: '[Comment removed]'});
        // delete media (if applicable)
        if (media != null) {
          return await _images.deleteImage(imageURL: media);
        }
      };
    }
    return null;
  }

  Future<void> likeComment() async {
    // remove dislike if disliked
    await commentRef!.update({
      C.dislikes: FieldValue.arrayRemove([userRef])
    });
    // like comment
    return await commentRef!.update({
      C.likes: FieldValue.arrayUnion([userRef])
    });
  }

  Future<void> unLikeComment() async {
    // remove like
    await commentRef!.update({
      C.likes: FieldValue.arrayRemove([userRef])
    });
  }

  Future<void> dislikeComment() async {
    // remove like if liked
    await commentRef!.update({
      C.likes: FieldValue.arrayRemove([userRef])
    });
    // dislike comment
    return await commentRef!.update({
      C.dislikes: FieldValue.arrayUnion([userRef])
    });
  }

  Future<void> unDislikeComment() async {
    // remove like
    await commentRef!.update({
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
