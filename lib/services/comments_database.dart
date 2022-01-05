import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:rxdart/rxdart.dart';

void defaultFunc(dynamic parameter) {}

class CommentsDatabaseService {
  final DocumentReference currUserRef;
  final DocumentReference? postRef;
  final DocumentReference? commentRef;
  final List<DocumentReference?>? commentsRefs;

  CommentsDatabaseService({required this.currUserRef, this.postRef, this.commentRef, this.commentsRefs});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference commentsCollection = FirebaseFirestore.instance.collection(C.comments);

  Future<dynamic> newComment(
      {required String text,
      required String? media,
      required DocumentReference postRef,
      required DocumentReference groupRef,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    DocumentReference newCommentRef = commentsCollection.doc();
    // update user's comments
    currUserRef.update({C.myCommentsRefs: FieldValue.arrayUnion([newCommentRef])});
    // update post's commentsRefs
    postRef.update({C.commentsRefs: FieldValue.arrayUnion([newCommentRef])});
    // get accessRestriction
    final group = await groupRef.get();
    final accessRestriction = group.get(C.accessRestriction);

    return await newCommentRef
        .set({
          C.postRef: postRef,
          C.groupRef: groupRef,
          C.creatorRef: currUserRef,
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
  }

  Future<dynamic> deleteComment(
      {required DocumentReference commentRef,
      required DocumentReference postRef,
      String? media}) async {
    // check comment exists and matches current user
    final comment = await commentRef.get();
    if (comment.exists) {
      if (currUserRef == comment.get(C.creatorRef)) {
        // update user's comments
        currUserRef.update({C.myCommentsRefs: FieldValue.arrayRemove([commentRef])});
        // update post's numComments
        postRef.update({C.commentsRefs: FieldValue.arrayRemove([commentRef])});
        // "delete" comment
        await commentRef
            .update({C.likes: [], C.dislikes: [], C.media: null, C.creatorRef: null, C.text: '[Comment removed]'});
        // delete media (if applicable)
        if (media != null) {
          return await _images.deleteImage(imageURL: media);
        }
      }
    }
    return null;
  }

  Future<void> likeComment() async {
    // remove dislike if disliked
    await commentRef!.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef])
    });
    // like comment
    return await commentRef!.update({
      C.likes: FieldValue.arrayUnion([currUserRef])
    });
  }

  Future<void> unLikeComment() async {
    // remove like
    await commentRef!.update({
      C.likes: FieldValue.arrayRemove([currUserRef])
    });
  }

  Future<void> dislikeComment() async {
    // remove like if liked
    await commentRef!.update({
      C.likes: FieldValue.arrayRemove([currUserRef])
    });
    // dislike comment
    return await commentRef!.update({
      C.dislikes: FieldValue.arrayUnion([currUserRef])
    });
  }

  Future<void> unDislikeComment() async {
    // remove like
    await commentRef!.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef])
    });
  }

  Comment? _commentFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    if (querySnapshot.exists) {
      return Comment.fromQuerySnapshot(querySnapshot);
    } else {
      return null;
    }
  }

  Comment? _commentFromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      return Comment.fromSnapshot(snapshot);
    } else {
      return null;
    }
  }

  Stream<List<Comment?>> get postComments {
    List<Stream<Comment?>> postCommentsList = <Stream<Comment?>>[];
    for (DocumentReference ref in (commentsRefs! as List<DocumentReference>)) {
      postCommentsList.add(ref.snapshots().map(_commentFromSnapshot));
    }
    // StreamZip won't rebuild when any comment changes, Rx.combineLatestList will
    return Rx.combineLatestList(postCommentsList);
  }
}
