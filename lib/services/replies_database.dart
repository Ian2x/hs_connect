import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

void defaultFunc(dynamic parameter) {}

class RepliesDatabaseService {
  final DocumentReference currUserRef;
  DocumentReference? postRef;
  DocumentReference? commentRef;
  DocumentReference? replyRef;


  RepliesDatabaseService({required this.currUserRef, this.commentRef, this.postRef, this.replyRef});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference repliesCollection = FirebaseFirestore.instance.collection(C.replies);

  Future newReply(
      {required String text,
      required String? media,
      required DocumentReference commentRef,
      required Post post,
      required DocumentReference groupRef,
      required DocumentReference postCreatorRef,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    DocumentReference newReplyRef = repliesCollection.doc();
    // update comment creator's activity if not self
    if (postCreatorRef != currUserRef) {
      postCreatorRef.update({C.myNotifications: FieldValue.arrayUnion([{
        C.parentPostRef: post.postRef,
        C.myNotificationType: MyNotificationType.replyToComment.string,
        C.sourceRef: newReplyRef,
        C.sourceUserRef: currUserRef,
        C.createdAt: Timestamp.now(),
        C.extraData: text
      }])});
    }
    // update other repliers' activity
    repliesCollection.where(C.commentRef, isEqualTo: commentRef).get().then(
        (QuerySnapshot QS) {
          final replies = QS.docs.map((QDS) =>_replyFromQuerySnapshot(QDS)).toList();
          for (Reply? r in replies) {
            if (r!=null) {
              // check not updating for multiple replies by self
              if (r.creatorRef!=currUserRef && r.creatorRef!=null) {
                r.creatorRef!.update({
                  C.myNotifications: FieldValue.arrayUnion([{
                    C.parentPostRef: post.postRef,
                    C.myNotificationType: MyNotificationType.replyToReply.string,
                    C.sourceRef: newReplyRef,
                    C.sourceUserRef: currUserRef,
                    C.createdAt: Timestamp.now(),
                    C.extraData: text
                  }])
                });
              }
            }
          }
        }
    );
    // update post's numReplies and score
    post.postRef.update({
      C.numReplies: FieldValue.increment(1),
      C.trendingCreatedAt: newTrendingCreatedAt(post.trendingCreatedAt.toDate(), trendingReplyBoost)
    });
    // get accessRestriction
    final group = await groupRef.get();
    final accessRestriction = group.get(C.accessRestriction);

    return await newReplyRef
        .set({
          C.creatorRef: currUserRef,
          C.commentRef: commentRef,
          C.postRef: post.postRef,
          C.groupRef: groupRef,
          C.accessRestriction: accessRestriction,
          C.text: text,
          C.mediaURL: media,
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
              .update({C.likes: [], C.dislikes: [], C.mediaURL: null, C.creatorRef: null, C.text: '[Reply removed]'});
        } else {
          // delete reply for good
          return await replyRef.delete();
        }
      }
    }
    return null;
  }

  Future<void> likeReply(DocumentReference replyCreatorRef, int likeCount) async {
    // update creator's likeCount
    replyCreatorRef.update({C.score: FieldValue.increment(1)});
    // remove dislike if disliked and like reply
    await replyRef!.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef]),
      C.likes: FieldValue.arrayUnion([currUserRef])
    });
    if (likeCount==1 || likeCount==10 || likeCount==20 || likeCount==50 || likeCount==100) {
      bool update = true;
      final replyCreatorData = await replyCreatorRef.get();
      final replyCreator = await userDataFromSnapshot(replyCreatorData, replyCreatorRef);
      for (MyNotification MN in replyCreator.myNotifications) {
        if (MN.sourceRef == replyRef! && MN.myNotificationType==MyNotificationType.replyVotes && MN.extraData==likeCount.toString()) {
          update = false;
          break;
        }
      }
      if (update) {
        replyCreatorRef.update({C.myNotifications: FieldValue.arrayUnion([{
          C.parentPostRef: postRef!,
          C.myNotificationType: MyNotificationType.replyVotes.string,
          C.sourceRef: replyRef!,
          C.sourceUserRef: currUserRef,
          C.createdAt: Timestamp.now(),
          C.extraData: likeCount.toString()
        }])});
      }
    }
  }

  Future<void> unLikeReply(DocumentReference replyCreatorRef) async {
    // update creator's likeCount
    replyCreatorRef.update({C.score: FieldValue.increment(-1)});
    // remove like
    await replyRef!.update({
      C.likes: FieldValue.arrayRemove([currUserRef])
    });
  }

  Future<void> dislikeReply() async {
    // remove like if liked and dislike reply
    await replyRef!.update({
      C.likes: FieldValue.arrayRemove([currUserRef]),
      C.dislikes: FieldValue.arrayUnion([currUserRef])
    });
  }

  Future<void> unDislikeReply() async {
    // remove like
    await replyRef!.update({
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
