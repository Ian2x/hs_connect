import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/observedRef.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

void defaultFunc(dynamic parameter) {}

class PostsDatabaseService {
  final DocumentReference currUserRef;
  List<DocumentReference>? groupRefs;
  List<String>? searchTags;

  PostsDatabaseService({required this.currUserRef, this.groupRefs, this.searchTags});

  ImageStorage _images = ImageStorage();

  // collection reference
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection(C.posts);
  late UserDataDatabaseService _userData = new UserDataDatabaseService(currUserRef: currUserRef);

  Future<dynamic> newPost({required String title,
    required String? text,
    required String? media,
    required DocumentReference groupRef,
    required String? tagString,
    required DocumentReference? pollRef,
    Function(void) onValue = defaultFunc,
    Function onError = defaultFunc}) async {
    // update user's posts
    DocumentReference newPostRef = postsCollection.doc();
    currUserRef.update({
      C.myPostsObservedRefs: FieldValue.arrayUnion([
        {C.ref: newPostRef, C.refType: ObservedRefType.post.string, C.lastObserved: Timestamp.now()}
      ])
    });
    // update group's numPosts
    groupRef.update({C.numPosts: FieldValue.increment(1)});
    // get accessRestriction
    final group = await groupRef.get();
    final accessRestriction = group.get(C.accessRestriction);

    final result = await newPostRef
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
      C.lastUpdated: DateTime.now(),
    })
        .then(onValue)
        .catchError(onError);
    GroupsDatabaseService _tempGroups = GroupsDatabaseService(currUserRef: currUserRef);
    _tempGroups.updateGroupStats(groupRef: groupRef);
    return result;
  }

  Future<dynamic> deletePost({required DocumentReference postRef,
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
        final myPostsObservedRefs = observedRefList((await currUserRef.get()).get(C.myPostsObservedRefs));
        for (final observedRef in myPostsObservedRefs) {
          if (observedRef.ref == postRef) {
            currUserRef.update({
              C.myPostsObservedRefs: FieldValue.arrayRemove([observedRef.asMap()])
            });
            break;
          }
        }

        // delete post's replies
        final delReplies = Future.forEach(post.get(C.repliesRefs), (item) async {
          final replyRef = item as DocumentReference;
          final reply = await replyRef.get();
          RepliesDatabaseService _tempReplies = RepliesDatabaseService(currUserRef: reply.get(C.creatorRef));
          // delete reply
          _tempReplies.deleteReply(
              replyRef: replyRef, commentRef: reply.get(C.commentRef), postRef: postRef, weakDelete: false);
        });

        // delete post's comments
        final delComments = Future.forEach(post.get(C.commentsRefs), (item) async {
          final commentRef = item as DocumentReference;
          final comment = await commentRef.get();
          CommentsDatabaseService _tempComments = CommentsDatabaseService(currUserRef: comment.get(C.creatorRef));
          // delete comment
          _tempComments.deleteComment(commentRef: commentRef, postRef: postRef, weakDelete: false);
        });

        var delPoll;
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
      }
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
      return postFromQuerySnapshot(querySnapshot);
    } else {
      return null;
    }
  }

  Post? _postFromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      return postFromSnapshot(snapshot);
    } else {
      return null;
    }
  }

  Future<Post?> getPost(DocumentReference postRef) async {
    return _postFromSnapshot(await postRef.get());
  }

  Future _getPostsHelper(DocumentReference PR, int index, List<Post?> results) async {
    results[index] = await getPost(PR);
  }

  // preserves order
  Future<List<Post?>> getPosts(List<DocumentReference> postsRefs) async {
    List<Post?> results = List.filled(postsRefs.length, null);
    await Future.wait([for (int i=0; i<postsRefs.length; i++) _getPostsHelper(postsRefs[i], i, results)]);
    return results;
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

  Future _newActivityPostsHelper(ObservedRef OR, List<Post> NAP) async {
    var tempPost = await getPost(OR.ref);
    if (tempPost != null) {
      if (tempPost.createdAt.compareTo(Timestamp.fromDate(DateTime.now().subtract(new Duration(days: 7)))) > 0) {
        if (tempPost.lastUpdated.compareTo(OR.lastObserved)>0) {
          tempPost.newActivity = true;
        }
        NAP.add(tempPost);
      }
    }
  }

  // Does not preserve order
  Future<List<Post>> newActivityPosts(List<ObservedRef> userPostsObservedRefs) async {
    List<Post> newActivityPosts = [];
    await Future.wait([for (ObservedRef POR in userPostsObservedRefs) _newActivityPostsHelper(POR, newActivityPosts)]);
    return newActivityPosts;
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
    final searchKeyLC = searchKey.toLowerCase();
    if (allowableGroupsRefs.length == 0) return Stream.empty();
    return postsCollection
        .where(C.groupRef, whereIn: allowableGroupsRefs)
        .where(C.titleLC, isGreaterThanOrEqualTo: searchKeyLC)
        .where(C.titleLC, isLessThan: searchKeyLC + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_searchResultFromQuerySnapshot).toList());
  }
}
