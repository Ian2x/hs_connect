import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/postCard.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class DomainFeed extends StatefulWidget {
  final UserData currUser;
  final bool isDomain;
  final bool searchByTrending;

  const DomainFeed({Key? key, required this.currUser, required this.isDomain, required this.searchByTrending}) : super(key: key);

  @override
  _DomainFeedState createState() => _DomainFeedState();
}

class _DomainFeedState extends State<DomainFeed> with AutomaticKeepAliveClientMixin<DomainFeed>{
  @override
  bool get wantKeepAlive => true;

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
      List<Post?> tempPosts = await _posts.getGroupPosts(
          [FirebaseFirestore.instance.collection(C.groups).doc(widget.currUser.domain)],
          startingFrom: pageKey, setStartFrom: (DocumentSnapshot ds) {tempKey = ds;}, withPublic: false, byNew: !widget.searchByTrending);
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
    if (!widget.isDomain) return Loading();

    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(top: 3*hp),
      child: RefreshIndicator(
        onRefresh: () =>
            Future.sync(
                  () => _pagingController.refresh(),
            ),
        child: PagedListView<DocumentSnapshot?, Post>(
          pagingController: _pagingController,
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          builderDelegate: PagedChildBuilderDelegate<Post>(
              itemBuilder: (context, item, index) {
                return Center(
                    child: PostCard(
                      post: item,
                currUserRef: widget.currUser.userRef,
              ));
            },
            noItemsFoundIndicatorBuilder: (BuildContext context) => Container(
                padding: EdgeInsets.only(top: 50 * hp),
                alignment: Alignment.topCenter,
                child: Text("No posts found",
                    style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.normal, color: colorScheme.onSurface))),
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
