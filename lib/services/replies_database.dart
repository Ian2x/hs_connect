import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';

void defaultFunc(dynamic parameter) {}

class RepliesDatabaseService {
  final DocumentReference? userRef;

  DocumentReference? commentRef;

  RepliesDatabaseService({this.userRef, this.commentRef});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference repliesCollection = FirebaseFirestore.instance.collection(C.replies);

  Future<DocumentReference> newReply(
      {required String text,
      required String? mediaURL,
      required DocumentReference commentRef,
      required DocumentReference postRef,
      required DocumentReference groupRef,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    postRef.update({C.numComments: FieldValue.increment(1)});
    commentRef.update({C.numReplies: FieldValue.increment(1)});

    final group = await groupRef.get();
    final accessRestriction = group.get(C.accessRestriction);

    return await repliesCollection
        .add({
          C.creatorRef: userRef,
          C.commentRef: commentRef,
          C.postRef: postRef,
          C.groupRef: groupRef,
          C.accessRestriction: accessRestriction,
          C.text: text,
          C.media: mediaURL,
          C.createdAt: DateTime.now(),
          C.likes: [],
          C.dislikes: [],
          C.reportsRefs: [],
        })
        .then(onValue)
        .catchError(onError);
  }

  Future<dynamic> deleteReply(
      {required DocumentReference replyRef,
      required DocumentReference commentRef,
      required DocumentReference postRef,
      required DocumentReference userRef,
      String? media}) async {
    final reply = await replyRef.get();
    if (reply.exists) {
      if (userRef == reply.get(C.creatorRef)) {
        postRef.update({C.numComments: FieldValue.increment(-1)});
        commentRef.update({C.numReplies: FieldValue.increment(1)});

        await replyRef
            .update({C.likes: [], C.dislikes: [], C.media: null, C.creatorRef: null, C.text: '[Reply removed]'});

        if (media != null) {
          return await _images.deleteImage(imageURL: media);
        }
      }
      ;
    }
    return null;
  }

  Future<void> likeReply({required DocumentReference replyRef, required DocumentReference userRef}) async {
    // remove dislike if disliked
    await replyRef.update({
      C.dislikes: FieldValue.arrayRemove([userRef])
    });
    // like comment
    return await replyRef.update({
      C.likes: FieldValue.arrayUnion([userRef])
    });
  }

  Future<void> unLikeReply({required DocumentReference replyRef, required DocumentReference userRef}) async {
    // remove like
    await replyRef.update({
      C.likes: FieldValue.arrayRemove([userRef])
    });
  }

  Future<void> dislikeReply({required DocumentReference replyRef, required DocumentReference userRef}) async {
    // remove like if liked
    await replyRef.update({
      C.likes: FieldValue.arrayRemove([userRef])
    });
    // dislike comment
    return await replyRef.update({
      C.dislikes: FieldValue.arrayUnion([userRef])
    });
  }

  Future<void> unDislikeReply({required DocumentReference replyRef, required DocumentReference userRef}) async {
    // remove like
    await replyRef.update({
      C.dislikes: FieldValue.arrayRemove([userRef])
    });
  }

  // home data from snapshot
  Reply? _replyFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    if (querySnapshot.exists) {
      return Reply.fromQuerySnapshot(querySnapshot);
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
