import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/services/storage/image_storage.dart';


void defaultFunc(dynamic parameter) {}

class CommentsDatabaseService {
  final DocumentReference? userRef;

  DocumentReference? postRef;

  CommentsDatabaseService({this.userRef, this.postRef});

  ImageStorage _images = ImageStorage();

  void setPostRef({required DocumentReference postRef}) {
    this.postRef = postRef;
  }

  // collection reference
  final CollectionReference commentsCollection = FirebaseFirestore.instance.collection('comments');

  Future newComment({required String text,
    required String? imageURL,
    required DocumentReference postRef,
    Function(void) onValue = defaultFunc,
    Function onError = defaultFunc}) async {
    return await commentsCollection
        .add({
      'userRef': userRef,
      'postREf': postRef,
      'text': text,
      'image': imageURL,
      'createdAt': DateTime.now(),
      'likes': List<String>.empty(),
      'dislikes': List<String>.empty(),
    })
        .then(onValue)
        .catchError(onError);
  }

  Future deleteComment({required DocumentReference commentRef, required DocumentReference userRef, String? media}) async {
    final checkAuth = await commentRef.get();
    if(checkAuth.exists) {
      if (userRef==checkAuth.get('userRef')) {
        await commentRef.delete();
        if (media!=null) {
          return await _images.deleteImage(imageURL: media);
        }
      };
    }
    return null;
  }

  Future likeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove dislike if disliked
    await commentRef.update({'dislikes': FieldValue.arrayRemove([userRef])});
    // like comment
    return await commentRef.update({'likes': FieldValue.arrayUnion([userRef])});
  }

  Future unLikeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove like
    await commentRef.update({'likes': FieldValue.arrayRemove([userRef])});
  }

  Future dislikeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove like if liked
    await commentRef.update({'likes': FieldValue.arrayRemove([userRef])});
    // dislike comment
    return await commentRef.update({'dislikes': FieldValue.arrayUnion([userRef])});
  }

  Future unDislikeComment({required DocumentReference commentRef, required DocumentReference userRef}) async {
    // remove like
    await commentRef.update({'dislikes': FieldValue.arrayRemove([userRef])});
  }

  // home data from snapshot
  Comment? _commentFromDocument(QueryDocumentSnapshot document) {
    if (document.exists) {
      return Comment(
        commentRef: document.reference,
        postRef: document['postRef'],
        userRef: document['userRef'],
        text: document['text'],
        media: document['image'],
        createdAt: document['createdAt'].toString(),
        numReplies: document['numReplies'],
        likes: (document['likes'] as List).map((item) => item as DocumentReference).toList(),
        dislikes: (document['dislikes'] as List).map((item) => item as DocumentReference).toList(),
      );
    } else {
      return null;
    }
  }

  Future<int> postNumComments({required DocumentReference postREf}) async {
    final data = await commentsCollection.where('postRef', isEqualTo: postRef).get();
    return data.size;
  }

  Stream<List<Comment?>> get postComments {
    return commentsCollection.where('postRef', isEqualTo: postRef).orderBy('createdAt', descending: false).snapshots().map((snapshot) => snapshot.docs.map(_commentFromDocument).toList());
  }

}
