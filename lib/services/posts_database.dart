import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

void defaultFunc(dynamic parameter) {}

class PostsDatabaseService {
  final DocumentReference currUserRef;
  final DocumentReference? postRef; // for liking/disliking posts

  PostsDatabaseService({required this.currUserRef, this.postRef});

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
    DocumentReference newPostRef = postsCollection.doc();
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
      C.mediaURL: media,
      C.createdAt: DateTime.now(),
      C.numComments: 0,
      C.numReplies: 0,
      C.accessRestriction: accessRestriction,
      C.likes: List<String>.empty(),
      C.dislikes: List<String>.empty(),
      C.numReports: 0,
      C.pollRef: pollRef,
      C.tag: tagString == '' ? null : tagString,
      C.score: 0,
      C.ianTime: DateTime.now().ianTime()
    })
        .then(onValue)
        .catchError(onError);
    GroupsDatabaseService _tempGroups = GroupsDatabaseService(currUserRef: currUserRef);
    _tempGroups.updateGroupStats(groupRef: groupRef);
    return result;
  }

  Future _delReplyHelper(Reply reply, DocumentReference postRef) async {
    RepliesDatabaseService _tempReplies = RepliesDatabaseService(currUserRef: reply.creatorRef);
    _tempReplies.deleteReply(
        replyRef: reply.replyRef, commentRef: reply.commentRef, postRef: postRef, weakDelete: false, media: reply.media);
  }

  Future _delCommentHelper(Comment comment, DocumentReference postRef) async {
    CommentsDatabaseService _tempComments = CommentsDatabaseService(currUserRef: comment.creatorRef);
    _tempComments.deleteComment(commentRef: comment.commentRef, postRef: postRef, weakDelete: false, media: comment.media);
  }

  Future<dynamic> deletePost({required DocumentReference postRef,
    required DocumentReference groupRef,
    required DocumentReference userRef,
    String? media}) async {
    // check post exists and matches current user
    final post = await postRef.get();
    if (post.exists) {
      // delete post first so UI can update
      final delPost = postRef.delete();

      if (userRef == post.get(C.creatorRef)) {
        // update group's numPosts
        groupRef.update({C.numPosts: FieldValue.increment(-1)});

        // delete post's replies in parallel
        final delReplies = Future(() async {
          final repliesData = await FirebaseFirestore.instance.collection(C.replies).where(C.postRef, isEqualTo: postRef).get();
          final replies = repliesData.docs.map((replyData) => replyFromQuerySnapshot(replyData));
          Future.wait([for (Reply reply in replies) _delReplyHelper(reply, postRef)]);
        });
        // delete post's comments in parallel
        final delComments = Future(() async {
          final commentsData = await FirebaseFirestore.instance.collection(C.comments).where(C.postRef, isEqualTo: postRef).get();
          final comments = commentsData.docs.map((commentData) => commentFromQuerySnapshot(commentData));
          Future.wait([for (Comment comment in comments) _delCommentHelper(comment, postRef)]);
        });

        var delPoll;
        // delete post's poll (if applicable)
        if (post.get(C.pollRef) != null) {
          delPoll = (post.get(C.pollRef) as DocumentReference).delete();
        }

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

  Future likePost(DocumentReference postCreatorRef, int likeCount) async {
    // remove dislike if disliked, like post, and +2 to score
    await postRef!.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef]),
      C.likes: FieldValue.arrayUnion([currUserRef]),
      C.score: FieldValue.increment(2)
    });
    // send notification if applicable
    if (likeCount==1 || likeCount==10 || likeCount==20 || likeCount==50 || likeCount==100) {
      bool update = true;
      final postCreatorData = await postCreatorRef.get();
      final postCreator = await userDataFromSnapshot(postCreatorData, postCreatorRef);
      for (MyNotification MN in postCreator.myNotifications) {
        if (MN.sourceRef == postRef! && MN.myNotificationType==MyNotificationType.postVotes && MN.extraData==likeCount.toString()) {
          update = false;
          break;
        }
      }
      if (update) {
        postCreatorRef.update({C.myNotifications: FieldValue.arrayUnion([{
          C.parentPostRef: postRef!,
          C.myNotificationType: MyNotificationType.postVotes.string,
          C.sourceRef: postRef!,
          C.sourceUserRef: currUserRef,
          C.createdAt: Timestamp.now(),
          C.extraData: likeCount.toString()
        }])});
      }
    }
  }

  Future unLikePost() async {
    // remove like and -2 to score
    await postRef!.update({
      C.likes: FieldValue.arrayRemove([currUserRef]),
      C.score: FieldValue.increment(-2)
    });
  }

  Future dislikePost() async {
    // remove like if liked, dislike post, and +1 to score
    await postRef!.update({
      C.likes: FieldValue.arrayRemove([currUserRef]),
      C.dislikes: FieldValue.arrayUnion([currUserRef]),
      C.score: FieldValue.increment(1)
    });
  }

  Future unDislikePost() async {
    // remove like and -1 to score
    await postRef!.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef]),
      C.score: FieldValue.increment(-1)
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

  Future<List<Post?>> getPostsByGroups (List<DocumentReference> groupRefs, {DocumentSnapshot? startingFrom, VoidDocSnapParamFunction? setStartFrom}) async {
    if (startingFrom!=null) {
      final data = await postsCollection
          .where(C.groupRef, whereIn: groupRefs)
          .orderBy(C.createdAt, descending: true)
          .startAfterDocument(startingFrom)
          .limit(2)
          .get();
      if (setStartFrom!=null) {
        setStartFrom(data.docs.last);
      }
      return data.docs.map(_postFromQuerySnapshot).toList();
    } else {
      final data = await postsCollection
          .where(C.groupRef, whereIn: groupRefs)
          .orderBy(C.createdAt, descending: true)
          .limit(5).get();
      if (setStartFrom!=null) {
        setStartFrom(data.docs.last);
      }
      return data.docs.map(_postFromQuerySnapshot).toList();
    }
  }

  Future<List<Post?>> getTrendingPosts (List<DocumentReference> groupRefs, {DocumentSnapshot? startingFrom, VoidDocSnapParamFunction? setStartFrom}) async {
    final int ianTime = DateTime.now().ianTime();
    if (startingFrom!=null) {
      final data = await postsCollection
          .where(C.ianTime, whereIn: [for (var i = 0; i < 10; i++) ianTime - i])
          .orderBy(C.score, descending: true)
          .startAfterDocument(startingFrom)
          .limit(2)
          .get();
      if (setStartFrom!=null) {
        setStartFrom(data.docs.last);
      }
      return data.docs.map(_postFromQuerySnapshot).toList();
    } else {
      final data = await postsCollection
          .where(C.ianTime, whereIn: [for (var i = 0; i < 10; i++) ianTime - i])
          .orderBy(C.score, descending: true)
          .limit(5)
          .get();
      if (setStartFrom!=null) {
        setStartFrom(data.docs.last);
      }
      return data.docs.map(_postFromQuerySnapshot).toList();
    }
  }

  /*Stream<List<Post?>> get posts {
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

  Future<List<Post?>> getUserPosts() async {
    final snapshot = await postsCollection.where(C.creatorRef, isEqualTo: currUserRef).get();
    return snapshot.docs.map(_postFromQuerySnapshot).toList();
  }

  Stream<List<Post?>> get potentialTrendingPosts {
    return postsCollection
        .where(C.createdAt,
        isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(new Duration(hours: hoursTrending))))
        .where(C.groupRef, whereIn: groupRefs)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_postFromQuerySnapshot).toList());
  }

  Stream<List<Post?>> get tagPosts {
    return postsCollection
        .where(C.tag, whereIn: searchTags)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_postFromQuerySnapshot).toList());
  }*/

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
