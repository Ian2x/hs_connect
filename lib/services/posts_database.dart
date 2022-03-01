import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/reply.dart';
import 'package:hs_connect/models/searchResult.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/replies_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

import 'my_notifications_database.dart';

void defaultFunc(dynamic parameter) {}

class PostsDatabaseService {
  final DocumentReference currUserRef;
  final DocumentReference? postRef; // for liking/disliking posts

  PostsDatabaseService({required this.currUserRef, this.postRef});

  static final ImageStorage _images = ImageStorage();

  // collection reference
  static final CollectionReference postsCollection = FirebaseFirestore.instance.collection(C.posts);

  Future<dynamic> newPost(
      {required String title,
      required String? text,
      required String? media,
      required DocumentReference groupRef,
      required String? tagString,
      required bool mature,
      required DocumentReference? pollRef,
      required String? link,
      Function(void) onValue = defaultFunc,
      Function onError = defaultFunc}) async {
    DocumentReference newPostRef = postsCollection.doc();
    // update group's numPosts
    groupRef.update({C.numPosts: FieldValue.increment(1)});
    // get accessRestriction
    final group = await groupRef.get();
    final accessRestriction = group.get(C.accessRestriction);
    // update user's last post time
    currUserRef.update({C.lastPostTime: Timestamp.now()});

    final result = await newPostRef
        .set({
          C.groupRef: groupRef,
          C.creatorRef: currUserRef,
          C.title: title.trim(),
          C.titleLC: title.trim().toLowerCase(),
          C.text: text?.trim(),
          C.mediaURL: media,
          C.createdAt: DateTime.now(),
          C.trendingCreatedAt: DateTime.now(),
          C.numComments: 0,
          C.numReplies: 0,
          C.accessRestriction: accessRestriction,
          C.likes: List<String>.empty(),
          C.dislikes: List<String>.empty(),
          C.numReports: 0,
          C.pollRef: pollRef,
          C.tag: tagString == '' ? null : tagString,
          C.isFeatured: false,
          C.mature: mature,
          C.link: httpsLink(link)
        })
        .then(onValue)
        .catchError(onError);
    return result;
  }

  Future _delReplyHelper(Reply reply, DocumentReference postRef) async {
    RepliesDatabaseService _tempReplies = RepliesDatabaseService(currUserRef: reply.creatorRef!);
    _tempReplies.deleteReply(
        replyRef: reply.replyRef,
        commentRef: reply.commentRef,
        postRef: postRef,
        weakDelete: false,
        media: reply.media);
  }

  Future _delCommentHelper(Comment comment, DocumentReference postRef) async {
    CommentsDatabaseService _tempComments = CommentsDatabaseService(currUserRef: comment.creatorRef!);
    _tempComments.deleteComment(
        commentRef: comment.commentRef, postRef: postRef, weakDelete: false, media: comment.media);
  }

  Future<dynamic> deletePost(
      {required DocumentReference postRef,
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
          final repliesData =
              await FirebaseFirestore.instance.collection(C.replies).where(C.postRef, isEqualTo: postRef).get();
          final replies = repliesData.docs.map((replyData) => replyFromQuerySnapshot(replyData));
          Future.wait([for (Reply reply in replies) _delReplyHelper(reply, postRef)]);
        });
        // delete post's comments in parallel
        final delComments = Future(() async {
          final commentsData =
              await FirebaseFirestore.instance.collection(C.comments).where(C.postRef, isEqualTo: postRef).get();
          final comments = commentsData.docs.map((commentData) => commentFromSnapshot(commentData));
          Future.wait([for (Comment comment in comments) _delCommentHelper(comment, postRef)]);
        });
        // delete post's notifications in parallel
        final delNotifications = Future(() async {
          final notificationsData = await FirebaseFirestore.instance
              .collection(C.myNotifications)
              .where(C.parentPostRef, isEqualTo: postRef)
              .get();
          final notificationsRefs = notificationsData.docs.map((notificationData) => notificationData.reference);
          Future.wait([for (DocumentReference ref in notificationsRefs) ref.delete()]);
        });

        var delPoll;
        // delete post's poll (if applicable)
        if (post.get(C.pollRef) != null) {
          delPoll = (post.get(C.pollRef) as DocumentReference).delete();
        }

        await delComments;
        await delReplies;
        await delNotifications;
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

  Future likePost(Post post, int likeCount) async {
    // update creator's likeCount
    post.creatorRef.update({C.score: FieldValue.increment(1)});
    // remove dislike if disliked, like post, and adjust trendingCreatedAt
    final newTCA = newTrendingCreatedAt(post.trendingCreatedAt.toDate(), trendingPostLikeBoost);
    post.trendingCreatedAt = Timestamp.fromDate(newTCA);
    await post.postRef.update({
      C.dislikes: FieldValue.arrayRemove([currUserRef]),
      C.likes: FieldValue.arrayUnion([currUserRef]),
      C.trendingCreatedAt: newTCA,
    });
    // send notification if applicable
    if (likeCount == 1 || likeCount == 10 || likeCount == 20 || likeCount == 50 || likeCount == 100) {
      bool update = true;
      final notifications = await MyNotificationsDatabaseService(userRef: post.creatorRef).getNotifications();
      for (MyNotification MN in notifications) {
        if (MN.sourceRef == post.postRef &&
            MN.myNotificationType == MyNotificationType.postVotes &&
            MN.extraData == likeCount.toString()) {
          update = false;
          break;
        }
      }
      if (update) {
        MyNotificationsDatabaseService(userRef: currUserRef).newNotification(
            parentPostRef: post.postRef,
            myNotificationType: MyNotificationType.postVotes,
            sourceRef: post.postRef,
            sourceUserRef: currUserRef,
            notifiedUserRef: post.creatorRef,
            extraData: likeCount.toString());
      }
    }
  }

  Future unLikePost(Post post) async {
    // update creator's likeCount
    post.creatorRef.update({C.score: FieldValue.increment(-1)});
    // remove like and adjust trendingCreatedAt
    final newTCA = undoNewTrendingCreatedAt(post.trendingCreatedAt.toDate(), trendingPostLikeBoost);
    post.trendingCreatedAt = Timestamp.fromDate(newTCA);
    await post.postRef.update({
      C.likes: FieldValue.arrayRemove([currUserRef]),
      C.trendingCreatedAt: newTCA
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
    await Future.wait([for (int i = 0; i < postsRefs.length; i++) _getPostsHelper(postsRefs[i], i, results)]);
    return results;
  }

  Future<List<Post?>> getGroupPosts(List<DocumentReference> groupRefs,
      {DocumentSnapshot? startingFrom,
      required VoidDocSnapParamFunction setStartFrom,
      required bool withPublic,
      required bool byNew}) async {
    // add public group
    if (withPublic) {
      groupRefs.add(FirebaseFirestore.instance.collection(C.groups).doc(C.Public));
    }
    if (startingFrom != null) {
      final data = await postsCollection
          .where(C.groupRef, whereIn: groupRefs)
          .orderBy(byNew ? C.createdAt : C.trendingCreatedAt, descending: true)
          .startAfterDocument(startingFrom)
          .limit(nextPostsFetchSize)
          .get();
      if (data.docs.isNotEmpty) {
        setStartFrom(data.docs.last);
      }
      return data.docs.map(_postFromSnapshot).toList();
    } else {
      final data = await postsCollection
          .where(C.groupRef, whereIn: groupRefs)
          .orderBy(byNew ? C.createdAt : C.trendingCreatedAt, descending: true)
          .limit(initialPostsFetchSize)
          .get();
      if (data.docs.isNotEmpty) {
        setStartFrom(data.docs.last);
      }
      return data.docs.map(_postFromSnapshot).toList();
    }
  }

  Future<List<Post?>> getUserPosts() async {
    final snapshot = await postsCollection.where(C.creatorRef, isEqualTo: currUserRef).get();
    return snapshot.docs.map(_postFromSnapshot).toList();
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
