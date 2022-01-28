import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/postCard.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class DomainFeed extends StatefulWidget {
  final UserData currUser;

  const DomainFeed({Key? key, required this.currUser}) : super(key: key);

  @override
  _DomainFeedState createState() => _DomainFeedState();
}

class _DomainFeedState extends State<DomainFeed> {

  static const _pageSize = 5;

  final PagingController<DocumentSnapshot?, Post> _pagingController = PagingController(firstPageKey: null);
  DocumentSnapshot? myPageKey;

  late PostsDatabaseService _posts;


  @override
  void initState() {
    _posts = PostsDatabaseService(currUserRef: widget.currUser.userRef);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(DocumentSnapshot? pageKey) async {
    try {
      DocumentSnapshot? tempKey;
      List<Post?> tempPosts = await _posts.getPostsByGroups(
          [FirebaseFirestore.instance.collection(C.groups).doc(widget.currUser.domain)],
          startingFrom: pageKey, setStartFrom: (DocumentSnapshot ds) {tempKey = ds;});
      tempPosts.removeWhere((value) => value == null);
      final newPosts = tempPosts.map((item) => item!).toList();

      final isLastPage = newPosts.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newPosts);
      } else {
        _pagingController.appendPage(newPosts, tempKey!);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) =>
      RefreshIndicator(
        onRefresh: () => Future.sync(
              () => _pagingController.refresh(),
        ),
        child: PagedListView<DocumentSnapshot?, Post>(
          pagingController: _pagingController,
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            //animateTransitions: true,
            itemBuilder: (context, item, index) {
              return Center(
                  child: PostCard(
                    post: item,
                    currUserRef: widget.currUser.userRef,
                  ));
            }
          ),
        ),
      );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
