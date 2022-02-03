import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/postCard.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class PublicFeed extends StatefulWidget {
  final UserData currUser;
  final Key pagedListViewKey;

  const PublicFeed({Key? key, required this.currUser, required this.pagedListViewKey})
      : super(key: key);

  @override
  _PublicFeedState createState() => _PublicFeedState();
}

class _PublicFeedState extends State<PublicFeed> with AutomaticKeepAliveClientMixin<PublicFeed>{
  @override
  bool get wantKeepAlive => false;

  static const _pageSize = nextPostsFetchSize;

  final PagingController<DocumentSnapshot?, Post> _pagingController = PagingController(firstPageKey: null);

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
      List<Post?> tempPosts = await _posts.getGroupPosts([],
          startingFrom: pageKey, setStartFrom: (DocumentSnapshot ds) {tempKey = ds;}, withPublic: true, byNew: false);
      tempPosts.removeWhere((value) => value == null);
      final newPosts = tempPosts.map((item) => item!).toList();
      final isLastPage = newPosts.length < _pageSize;
      if (mounted) {
        if (isLastPage) {
          _pagingController.appendLastPage(newPosts);
        } else {
          _pagingController.appendPage(newPosts, tempKey!);
        }
      }
    } catch (error) {
      _pagingController.error = error;
      print(error.runtimeType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;

    return Container(
      padding: EdgeInsets.only(top: 3*hp),
      child: RefreshIndicator(
        onRefresh: () =>
            Future.sync(
                  () => _pagingController.refresh(),
            ),
        child: PagedListView<DocumentSnapshot?, Post>(
          pagingController: _pagingController,
          key: widget.pagedListViewKey,
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
              },
              noItemsFoundIndicatorBuilder: (BuildContext context) => Container(
                  padding: EdgeInsets.only(top: 50*hp),
                  alignment: Alignment.topCenter,
                  child: Text("No posts found",
                      style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
