import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/postCard.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/myStorageManager.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class MergeFeed extends StatefulWidget {
  final UserData currUserData;
  final bool isDomain;
  final bool searchByTrending;

  const MergeFeed({Key? key, required this.currUserData, required this.isDomain, required this.searchByTrending})
      : super(key: key);

  @override
  _MergeFeedState createState() => _MergeFeedState();
}

class _MergeFeedState extends State<MergeFeed> with AutomaticKeepAliveClientMixin<MergeFeed> {
  @override
  bool get wantKeepAlive => true;

  static const _pageSize = nextPostsFetchSize;

  final PagingController<DocumentSnapshot?, Post> _pagingController = PagingController(firstPageKey: null);

  late PostsDatabaseService _posts;

  bool? showMaturePosts;

  @override
  void initState() {
    _posts = PostsDatabaseService(currUserRef: widget.currUserData.userRef);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    getShowMaturePosts();
    super.initState();
  }

  void getShowMaturePosts() async {
    final data = await MyStorageManager.readData('mature');
    if (mounted) {
      if (data == false) {
        setState(() => showMaturePosts = false);
      } else {
        setState(() => showMaturePosts = true);
      }
    }
  }

  Future<void> _fetchPage(DocumentSnapshot? pageKey) async {
    try {
      DocumentSnapshot? tempKey;
      List<Post?> tempPosts =
      await _posts.getGroupPosts([FirebaseFirestore.instance.collection(C.groups).doc(widget.currUserData.domain)], startingFrom: pageKey, setStartFrom: (DocumentSnapshot ds) {
        tempKey = ds;
      }, withPublic: true, byNew: !widget.searchByTrending);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.isDomain || showMaturePosts == null) return Loading();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: RefreshIndicator(
        onRefresh: () => Future.sync(
              () => _pagingController.refresh(),
        ),
        child: PagedListView<DocumentSnapshot?, Post>(
          pagingController: _pagingController,
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            //animateTransitions: true,
            itemBuilder: (context, post, index) {
              if ((!(showMaturePosts!) && post.mature) ||
                  (widget.currUserData.blockedPostRefs.contains(post.postRef)) ||
                  (widget.currUserData.blockedUserRefs.contains(post.creatorRef))) {
                return Container();
              }
              return Center(
                  child: PostCard(
                    post: post,
                    currUserData: widget.currUserData,
                  ));
            },
            noItemsFoundIndicatorBuilder: (BuildContext context) => Container(
                padding: EdgeInsets.only(top: 50),
                alignment: Alignment.topCenter,
                child: Text("No messages found",
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(color: colorScheme.onSurface))),
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
