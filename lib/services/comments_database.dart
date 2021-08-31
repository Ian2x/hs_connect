import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';


void defaultFunc(dynamic parameter) {}

class CommentsDatabaseService {
  final String? userId;

  String? postId;

  CommentsDatabaseService({this.userId, this.postId});

  void setPostId({required String postid}) {
    this.postId = postId;
  }

  // collection reference
  final CollectionReference commentsCollection = FirebaseFirestore.instance.collection('comments');

  Future newComment({required String? replyToId, required String text,
    required String? imageURL,
    required String postId,
    Function(void) onValue = defaultFunc,
    Function onError = defaultFunc}) async {
    return await commentsCollection
        .add({
      'userId': userId,
      'postId': postId,
      'replyToId': replyToId,
      'text': text,
      'image': imageURL == null || imageURL == '' ? '' : imageURL,
      'createdAt': DateTime.now(),
      'likes': List<String>.empty(),
      'dislikes': List<String>.empty(),
    })
        .then(onValue)
        .catchError(onError);
  }

  // home data from snapshot
  Comment? _commentFromDocument(QueryDocumentSnapshot document) {
    if (document.exists) {
      return Comment(
        commentId: document.id,
        replyToId: document['replyToId'],
        postId: document['postId'],
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

  Stream<List<Comment?>> get postComments {
    return commentsCollection.where('postId', isEqualTo: postId).snapshots().map((snapshot) => snapshot.docs.map(_commentFromDocument).toList());
  }

}
