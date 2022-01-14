import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';

void defaultFunc(dynamic parameter) {}

class RepliesDatabaseService {
  final DocumentReference currUserRef;
  DocumentReference? commentRef;

  RepliesDatabaseService({required this.currUserRef, this.commentRef});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference repliesCollection = FirebaseFirestore.instance.collection(C.replies);

  Future<DocumentReference> newReply(
      {required String text,
      required String? media,
      required DocumentReference commentRef,
      required DocumentReference postRef,
      required DocumentReference groupRef,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    DocumentReference newReplyRef = repliesCollection.doc();
    // update user's replies
    currUserRef.update({
      C.numReplies: FieldValue.increment(1)
    });
    // update post's repliesRefs and lastUpdated
    postRef.update({
      C.numReplies: FieldValue.increment(1),
      C.lastUpdated: DateTime.now()
    });
    // update comment's numReplies and lastUpdated
    commentRef.update({
      C.numReplies: FieldValue.increment(1),
      C.lastUpdated: DateTime.now()
    });
    // get accessRestriction
    final group = await groupRef.get();
    final accessRestriction = group.get(C.accessRestriction);

    return await newReplyRef
        .set({
          C.creatorRef: currUserRef,
          C.commentRef: commentRef,
          C.postRef: postRef,
          C.groupRef: groupRef,
          C.accessRestriction: accessRestriction,
          C.text: text,
          C.media: media,
          C.createdAt: DateTime.now(),
          C.likes: [],
          C.dislikes: [],
          C.numReports: 0,
        })
        .then(onValue)
        .catchError(onError);
  }

  Future<dynamic> deleteReply(
      {required DocumentReference replyRef,
      required DocumentReference commentRef,
      required DocumentReference postRef,
      bool weakDelete = true,
      String? media}) async {
    final reply = await replyRef.get();
    if (reply.exists) {
      if (currUserRef == reply.get(C.creatorRef)) {
        // update user's replies
        currUserRef.update({
          C.numReplies: FieldValue.increment(-1)
        });
        // update post's repliesRefs
        // postRef.update({C.repliesRefs: FieldValue.arrayRemove([replyRef])});
        // update comment's numReplies
        // commentRef.update({C.numReplies: FieldValue.increment(-1)});

        // delete media (if applicable)
        if (media != null) {
          await _images.deleteImage(imageURL: media);
        }

        if (weakDelete) {
          // "delete" reply
          return await replyRef
              .update({C.likes: [], C.dislikes: [], C.media: null, C.creatorRef: null, C.text: '[Reply removed]'});
        } else {
          // delete reply for good
          return await replyRef.delete();
        }
      }
    }
    return null;
  }

  Future<void> likeReply({required DocumentReference replyRef}) async {
    // remove dislike if disliked
    await replyRef.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef])
    });
    // like comment
    return await replyRef.update({
      C.likes: FieldValue.arrayUnion([currUserRef])
    });
  }

  Future<void> unLikeReply({required DocumentReference replyRef}) async {
    // remove like
    await replyRef.update({
      C.likes: FieldValue.arrayRemove([currUserRef])
    });
  }

  Future<void> dislikeReply({required DocumentReference replyRef}) async {
    // remove like if liked
    await replyRef.update({
      C.likes: FieldValue.arrayRemove([currUserRef])
    });
    // dislike comment
    return await replyRef.update({
      C.dislikes: FieldValue.arrayUnion([currUserRef])
    });
  }

  Future<void> unDislikeReply({required DocumentReference replyRef}) async {
    // remove like
    await replyRef.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef])
    });
  }

  // home data from snapshot
  Reply? _replyFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    if (querySnapshot.exists) {
      return replyFromQuerySnapshot(querySnapshot);
    } else {
      return null;
    }
  }

  Stream<List<Reply?>> get commentReplies {
    return repliesCollection
        .where(C.commentRef, isEqualTo: commentRef)
        .orderBy(C.createdAt, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_replyFromQuerySnapshot).toList());
  }
}
