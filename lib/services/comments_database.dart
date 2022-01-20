import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
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
      required DocumentReference postCreatorRef,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    DocumentReference newCommentRef = commentsCollection.doc();
    // update post creator's activity
    postCreatorRef.update({C.myNotifications: FieldValue.arrayUnion([{
      C.parentPostRef: postRef,
      C.myNotificationType: MyNotificationType.commentToPost.string,
      C.sourceRef: newCommentRef,
      C.sourceUserRef: currUserRef,
      C.createdAt: Timestamp.now(),
      C.extraData: text
    }])});

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

  Future<void> likeComment(DocumentReference commentCreatorRef, int likeCount) async {
    // remove dislike if disliked
    await commentRef!.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef])
    });
    // like comment
    await commentRef!.update({
      C.likes: FieldValue.arrayUnion([currUserRef])
    });
    if (likeCount==1 || likeCount==10 || likeCount==20 || likeCount==50 || likeCount==100) {
      bool update = true;
      final commentCreatorData = await commentCreatorRef.get();
      final commentCreator = await userDataFromSnapshot(commentCreatorData, commentCreatorRef);
      for (MyNotification MN in commentCreator.myNotifications) {
        if (MN.sourceRef == commentRef! && MN.myNotificationType==MyNotificationType.commentVotes && MN.extraData==likeCount.toString()) {
          update = false;
          break;
        }
      }
      if (update) {
        commentCreatorRef.update({C.myNotifications: FieldValue.arrayUnion([{
          C.parentPostRef: postRef!,
          C.myNotificationType: MyNotificationType.commentVotes.string,
          C.sourceRef: commentRef!,
          C.sourceUserRef: currUserRef,
          C.createdAt: Timestamp.now(),
          C.extraData: likeCount.toString()
        }])});
      }
    }
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

  Stream get postComments {
    return commentsCollection
      .where('postRef', isEqualTo: postRef!)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_commentFromQuerySnapshot).toList());
  }
}
