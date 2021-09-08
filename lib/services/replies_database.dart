import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/reply.dart';

void defaultFunc(dynamic parameter) {}

class RepliesDatabaseService {
  final String? userId;

  String? commentId;

  RepliesDatabaseService({this.userId, this.commentId});

  void setCommentId({required String commentId}) {
    this.commentId = commentId;
  }

  // collection reference
  final CollectionReference repliesCollection = FirebaseFirestore.instance.collection('replies');

  Future newReply({required String text,
    required String? imageURL,
    required String commentId,
    Function(void) onValue = defaultFunc,
    Function onError = defaultFunc}) async {
    return await repliesCollection
        .add({
      'userId': userId,
      'commentId': commentId,
      'text': text,
      'image': imageURL == null || imageURL == '' ? '' : imageURL,
      'createdAt': DateTime.now(),
      'likes': List<String>.empty(),
      'dislikes': List<String>.empty(),
    })
        .then(onValue)
        .catchError(onError);
  }

  Future deleteReply({required String replyId, required String userId}) async {
    final checkAuth = await repliesCollection.doc(replyId).get();
    if(checkAuth.exists) {
      if (userId==checkAuth.get('userId')) {
        return await repliesCollection.doc(replyId).delete();
      };
    }
    return null;
  }

  Future likeReply({required String replyId, required String userId}) async {
    // remove dislike if disliked
    await repliesCollection.doc(replyId).update({'dislikes': FieldValue.arrayRemove([userId])});
    // like comment
    return await repliesCollection.doc(replyId).update({'likes': FieldValue.arrayUnion([userId])});
  }

  Future unLikeReply({required String replyId, required String userId}) async {
    // remove like
    await repliesCollection.doc(replyId).update({'likes': FieldValue.arrayRemove([userId])});
  }


  Future dislikeReply({required String replyId, required String userId}) async {
    // remove like if liked
    await repliesCollection.doc(replyId).update({'likes': FieldValue.arrayRemove([userId])});
    // dislike comment
    return await repliesCollection.doc(replyId).update({'dislikes': FieldValue.arrayUnion([userId])});
  }

  Future unDislikeReply({required String replyId, required String userId}) async {
    // remove like
    await repliesCollection.doc(replyId).update({'dislikes': FieldValue.arrayRemove([userId])});
  }

  // home data from snapshot
  Reply? _replyFromDocument(QueryDocumentSnapshot document) {
    if (document.exists) {
      return Reply(
        replyId: document.id,
        commentId: document['commentId'],
        userId: document['userId'],
        text: document['text'],
        image: document['image'],
        createdAt: document['createdAt'].toString(),
        likes: (document['likes'] as List).map((item) => item as String).toList(),
        dislikes: (document['dislikes'] as List).map((item) => item as String).toList(),//document['dislikes'],
      );
    } else {
      return null;
    }
  }

  Stream<List<Reply?>> get commentReplies {
    return repliesCollection.where('commentId', isEqualTo: commentId).orderBy('createdAt', descending: false).snapshots().map((snapshot) => snapshot.docs.map(_replyFromDocument).toList());
  }

}
