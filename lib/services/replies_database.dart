import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/services/storage/image_storage.dart';

void defaultFunc(dynamic parameter) {}

class RepliesDatabaseService {
  final DocumentReference? userRef;

  DocumentReference? commentRef;

  RepliesDatabaseService({this.userRef, this.commentRef});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference repliesCollection = FirebaseFirestore.instance.collection('replies');

  Future newReply({required String text,
    required String? mediaURL,
    required DocumentReference commentRef,
    required DocumentReference postRef,
    Function(void) onValue = defaultFunc,
    Function onError = defaultFunc}) async {

    postRef.update({'numComments': FieldValue.increment(1)});
    commentRef.update({'numReplies': FieldValue.increment(1)});

    return await repliesCollection
        .add({
      'userRef': userRef,
      'commentRef': commentRef,
      'postRef': postRef,
      'text': text,
      'media': mediaURL,
      'createdAt': DateTime.now(),
      'likes': List<String>.empty(),
      'dislikes': List<String>.empty(),
      'reportedStatus': null,
    })
        .then(onValue)
        .catchError(onError);
  }

  Future deleteReply({required DocumentReference replyRef, required DocumentReference commentRef, required DocumentReference postRef, required DocumentReference userRef, String? media}) async {
    final checkAuth = await replyRef.get();
    if(checkAuth.exists) {
      if (userRef==checkAuth.get('userRef')) {

        postRef.update({'numComments': FieldValue.increment(-1)});
        commentRef.update({'numReplies': FieldValue.increment(1)});

        await replyRef.update({'likes': [], 'dislikes': [], 'media': null, 'userRef': null, 'text': '[Reply removed]'});

        if (media!=null) {
          return await _images.deleteImage(imageURL: media);
        }
      };
    }
    return null;
  }

  Future likeReply({required DocumentReference replyRef, required DocumentReference userRef}) async {
    // remove dislike if disliked
    await replyRef.update({'dislikes': FieldValue.arrayRemove([userRef])});
    // like comment
    return await replyRef.update({'likes': FieldValue.arrayUnion([userRef])});
  }

  Future unLikeReply({required DocumentReference replyRef, required DocumentReference userRef}) async {
    // remove like
    await replyRef.update({'likes': FieldValue.arrayRemove([userRef])});
  }


  Future dislikeReply({required DocumentReference replyRef, required DocumentReference userRef}) async {
    // remove like if liked
    await replyRef.update({'likes': FieldValue.arrayRemove([userRef])});
    // dislike comment
    return await replyRef.update({'dislikes': FieldValue.arrayUnion([userRef])});
  }

  Future unDislikeReply({required DocumentReference replyRef, required DocumentReference userRef}) async {
    // remove like
    await replyRef.update({'dislikes': FieldValue.arrayRemove([userRef])});
  }

  // home data from snapshot
  Reply? _replyFromDocument(QueryDocumentSnapshot document) {
    if (document.exists) {
      return Reply(
        replyRef: document.reference,
        commentRef: document['commentRef'],
        postRef: document['postRef'],
        userRef: document['userRef'],
        text: document['text'],
        media: document['media'],
        createdAt: document['createdAt'].toString(),
        likes: (document['likes'] as List).map((item) => item as DocumentReference).toList(),
        dislikes: (document['dislikes'] as List).map((item) => item as DocumentReference).toList(),//document['dislikes'],
        reportedStatus: document['reportedStatus'],
      );
    } else {
      return null;
    }
  }

  Stream<List<Reply?>> get commentReplies {
    return repliesCollection.where('commentRef', isEqualTo: commentRef).orderBy('createdAt', descending: false).snapshots().map((snapshot) => snapshot.docs.map(_replyFromDocument).toList());
  }

}
