import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/observedRef.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:rxdart/rxdart.dart';

void defaultFunc(dynamic parameter) {}

class CommentsDatabaseService {
  final DocumentReference currUserRef;
  final DocumentReference? postRef;
  final DocumentReference? commentRef;

  CommentsDatabaseService({required this.currUserRef, this.postRef, this.commentRef});

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
    // update user's comments
    DocumentReference newCommentRef = commentsCollection.doc();
    currUserRef.update({
      C.myCommentsObservedRefs: FieldValue.arrayUnion([
        {C.ref: newCommentRef, C.refType: ObservedRefType.comment.string, C.lastObserved: Timestamp.now()}
      ])
    });
    // update post's commentsRefs and lastUpdated
    postRef.update({
      C.numComments: FieldValue.increment(1),
      C.lastUpdated: DateTime.now(),
    });
    // get accessRestriction
    final group = await groupRef.get();
    final accessRestriction = group.get(C.accessRestriction);

    return await newCommentRef
        .set({
          C.postRef: postRef,
          C.groupRef: groupRef,
          C.creatorRef: currUserRef,
          C.text: text,
          C.mediaURL: media,
          C.createdAt: DateTime.now(),
          C.numReplies: 0,
          C.accessRestriction: accessRestriction,
          C.likes: [],
          C.dislikes: [],
          C.numReports: 0,
          C.lastUpdated: DateTime.now(),
        })
        .then(onValue)
        .catchError(onError);
  }

  Future<dynamic> deleteComment(
      {required DocumentReference commentRef,
      required DocumentReference postRef,
      bool weakDelete = true,
      String? media}) async {
    // check comment exists and matches current user
    final comment = await commentRef.get();
    if (comment.exists) {
      if (currUserRef == comment.get(C.creatorRef)) {
        // update post's numComments
        // postRef.update({C.commentsRefs: FieldValue.arrayRemove([commentRef])});
        // update user's comments
        final myCommentsObservedRefs = observedRefList((await currUserRef.get()).get(C.myCommentsObservedRefs));
        for (final observedRef in myCommentsObservedRefs) {
          if (observedRef.ref == commentRef) {
            currUserRef.update({
              C.myCommentsObservedRefs: FieldValue.arrayRemove([observedRef.asMap()])
            });
            break;
          }
        }

        // delete media (if applicable)
        if (media != null) {
          _images.deleteImage(imageURL: media);
        }

        if (weakDelete) {
          // "delete" comment
          return await commentRef
              .update({C.likes: [], C.dislikes: [], C.mediaURL: null, C.creatorRef: null, C.text: '[Comment removed]'});
        } else {
          // delete comment for good
          return await commentRef.delete();
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
      return commentFromQuerySnapshot(querySnapshot);
    } else {
      return null;
    }
  }

  Comment? _commentFromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      return commentFromSnapshot(snapshot);
    } else {
      return null;
    }
  }

  Future<Comment?> getComment(DocumentReference commentRef) async {
    return _commentFromSnapshot(await commentRef.get());
  }

  // doesn't preserve order
  Future _newActivityCommentsHelper(ObservedRef OR, List<Comment> NAC) async {
    var tempComment = await getComment(OR.ref);
    if (tempComment != null) {
      if (tempComment.lastUpdated.toDate().compareTo(OR.lastObserved.toDate().add(Duration(seconds: 2)))>0) {
        NAC.add(tempComment);
      }
    }
  }
  Future<List<Comment>> newActivityComments(List<ObservedRef> userCommentsObservedRefs) async {
    List<Comment> newActivityComments = [];
    await Future.wait([for (ObservedRef COR in userCommentsObservedRefs) _newActivityCommentsHelper(COR, newActivityComments)]);
    return newActivityComments;
  }

  Stream get postComments {
    return commentsCollection
      .where('postRef', isEqualTo: postRef!)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_commentFromQuerySnapshot).toList());
  }
}
