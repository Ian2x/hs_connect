import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';

void defaultFunc(dynamic parameter) {}

class PostsDatabaseService {
  final DocumentReference currUserRef;
  List<DocumentReference>? groupRefs;
  List<String>? searchTags;

  PostsDatabaseService({required this.currUserRef, this.groupRefs, this.searchTags});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection(C.posts);

  Future<dynamic> newPost(
      {required String title,
      required String? text,
      required String? media,
      required DocumentReference groupRef,
      required String? tagString,
      required DocumentReference? pollRef,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    // get accessRestriction
    final group = await groupRef.get();
    final accessRestriction = group.get(C.accessRestriction);
    // update group's numPosts
    groupRef.update({C.numPosts: FieldValue.increment(1)});
    // update user's posts
    DocumentReference postRef = postsCollection.doc();
    currUserRef.update({C.myPostsRefs: FieldValue.arrayUnion([postRef])});

    return await postRef
        .set({
          C.groupRef: groupRef,
          C.creatorRef: currUserRef,
          C.title: title,
          C.titleLC: title.toLowerCase(),
          C.text: text,
          C.media: media,
          C.createdAt: DateTime.now(),
          C.commentsRefs: [],
          C.repliesRefs: [],
          C.accessRestriction: accessRestriction,
          C.likes: List<String>.empty(),
          C.dislikes: List<String>.empty(),
          C.reportsRefs: [],
          C.pollRef: pollRef,
          C.tag: tagString == '' ? null : tagString,
        })
        .then(onValue)
        .catchError(onError);
  }

  Future<dynamic> deletePost(
      {required DocumentReference postRef,
      required DocumentReference groupRef,
      required DocumentReference userRef,
      String? media}) async {
    // check post exists and matches current user
    final post = await postRef.get();
    if (post.exists) {
      if (userRef == post.get(C.creatorRef)) {
        // update group's numPosts
        groupRef.update({C.numPosts: FieldValue.increment(-1)});
        // update user's posts
        currUserRef.update({C.myCommentsRefs: FieldValue.arrayRemove([postRef])});

        // delete post's replies
        final delReplies = Future.forEach(post.get(C.repliesRefs), (item) async {
          final replyRef = item as DocumentReference;
          final reply = await replyRef.get();
          // remove reply from its creator
          (reply.get(C.creatorRef) as DocumentReference).update({C.myRepliesRefs: FieldValue.arrayRemove([replyRef])});
          // delete media (if applicable)
          if (reply.get(C.media) != null) {
            _images.deleteImage(imageURL: reply.get(C.media));
          }
          // delete reply for good
          return await replyRef.delete();
        });

        // delete post's comments
        final delComments = Future.forEach(post.get(C.commentsRefs), (item) async {
          final commentRef = item as DocumentReference;
          final comment = await commentRef.get();
          // remove comment from its creator
          (comment.get(C.creatorRef) as DocumentReference).update({C.myCommentsRefs: FieldValue.arrayRemove([commentRef])});
          // delete media (if applicable)
          if (comment.get(C.media) != null) {
            _images.deleteImage(imageURL: comment.get(C.media));
          }
          // delete comment for good
          return await commentRef.delete();
        });

        var delPoll = null;
        // delete post's poll (if applicable)
        if (post.get(C.pollRef) != null) {
          delPoll = (post.get(C.pollRef) as DocumentReference).delete();
        }

        // delete post
        final delPost = postRef.delete();

        await delComments;
        await delReplies;
        await delPoll;
        await delPost;
        // delete image
        if (media != null) {
          return await _images.deleteImage(imageURL: media);
        }
      };
    }
    return null;
  }

  Future<void> likePost({required DocumentReference postRef}) async {
    // remove dislike if disliked
    await postRef.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef])
    });
    // like comment
    return await postRef.update({
      C.likes: FieldValue.arrayUnion([currUserRef])
    });
  }

  Future<void> unLikePost({required DocumentReference postRef}) async {
    // remove like
    await postRef.update({
      C.likes: FieldValue.arrayRemove([currUserRef])
    });
  }

  Future<void> dislikePost({required DocumentReference postRef}) async {
    // remove like if liked
    await postRef.update({
      C.likes: FieldValue.arrayRemove([currUserRef])
    });
    // dislike comment
    return await postRef.update({
      C.dislikes: FieldValue.arrayUnion([currUserRef])
    });
  }

  Future<void> unDislikePost({required DocumentReference postRef}) async {
    // remove like
    await postRef.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef])
    });
  }

  // home data from snapshot
  Post? _postFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    if (querySnapshot.exists) {
      return Post.fromQuerySnapshot(querySnapshot);
    } else {
      return null;
    }
  }

  Post? _postFromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      return Post.fromSnapshot(snapshot);
    } else {
      return null;
    }
  }

  Future<Post?> getPost(DocumentReference postRef) async {
    return _postFromSnapshot(await postRef.get());
  }

  Stream<List<Post?>> get posts {
    return postsCollection
        .where(C.groupRef, whereIn: groupRefs)
        .orderBy(C.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_postFromQuerySnapshot).toList());
  }

  Future<List<Post?>> getMultiGroupPosts() async {
    final snapshot = await postsCollection.where(C.groupRef, whereIn: groupRefs).get();
    return snapshot.docs.map(_postFromQuerySnapshot).toList();
  }

  Stream<List<Post?>> get potentialTrendingPosts {
    return postsCollection
        .where(C.createdAt,
            isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(new Duration(days: daysTrending))))
        .where(C.groupRef, whereIn: groupRefs)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_postFromQuerySnapshot).toList());
  }

  Stream<List<Post?>> get tagPosts {
    return postsCollection
        .where(C.tag, whereIn: searchTags)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_postFromQuerySnapshot).toList());
  }

  SearchResult _searchResultFromQuerySnapshot(QueryDocumentSnapshot querySnapshot) {
    return SearchResult(
      resultRef: querySnapshot.reference,
      resultType: SearchResultType.posts,
      resultDescription: querySnapshot[C.createdAt].toString(),
      resultText: querySnapshot[C.title],
    );
  }

  Stream<List<SearchResult>> searchStream(String searchKey, List<DocumentReference> allowableGroupsRefs) {
    final LCsearchKey = searchKey.toLowerCase();
    if (allowableGroupsRefs.length == 0) return Stream.empty();
    return postsCollection
        .where(C.groupRef, whereIn: allowableGroupsRefs)
        .where(C.titleLC, isGreaterThanOrEqualTo: LCsearchKey)
        .where(C.titleLC, isLessThan: LCsearchKey + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_searchResultFromQuerySnapshot).toList());
  }
}
