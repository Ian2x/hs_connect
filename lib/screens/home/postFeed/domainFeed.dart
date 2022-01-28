import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/postsListView.dart';
import 'package:provider/provider.dart';

class DomainFeed extends StatefulWidget {
  final UserData currUser;

  const DomainFeed({Key? key, required this.currUser}) : super(key: key);

  @override
  _DomainFeedState createState() => _DomainFeedState();
}

class _DomainFeedState extends State<DomainFeed> {
  final scrollController = ScrollController();
  List<Post> posts = [];
  DocumentSnapshot? lastVisiblePost;

  late PostsDatabaseService _posts;

  @override
  void initState() {
    _posts = PostsDatabaseService(currUserRef: widget.currUser.userRef);
    getInitialPosts();
    scrollController.addListener(() {
      //print(widget.scrollController.position.extentBefore);
      //widget.scrollController.position.pixels;
      //if (widget.scrollController.position.extentAfter())
      /*if (widget.scrollController.position.atEdge) {
        if (widget.scrollController.position.pixels != 0) {
          getNextPosts();
        }
      }*/
      if (scrollController.position.atEdge && scrollController.position.pixels != 0 || scrollController.position.extentAfter<10) {
        print('doing something');
        getNextPosts();
        //widget.scrollController.notifyListeners();
        //widget.scrollController.animateTo(widget.scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    return RefreshIndicator(
        child: postsListView(posts: posts, currUserRef: userData.userRef, scrollController: scrollController),
        onRefresh: getInitialPosts
    );
  }

  Future getInitialPosts() async {
    List<Post?> tempPosts = await _posts.getPostsByGroups(
        [FirebaseFirestore.instance.collection(C.groups).doc(widget.currUser.domain)],
        setStartFrom: setLastVisiblePost);
    tempPosts.removeWhere((value) => value == null);
    if (mounted) {
      setState(() {
        posts = tempPosts.map((item) => item!).toList();
      });
    }
  }

  Future getNextPosts() async {
    print('getting next posts');
    List<Post?> tempPosts = await _posts.getPostsByGroups(
        [FirebaseFirestore.instance.collection(C.groups).doc(widget.currUser.domain)],
        startingFrom: lastVisiblePost!, setStartFrom: setLastVisiblePost);
    tempPosts.removeWhere((value) => value == null);
    if (mounted) {
      setState(() {
        posts = posts + tempPosts.map((item) => item!).toList();
      });
    }
  }

  void setLastVisiblePost(DocumentSnapshot ds) {
    if (mounted) {
      setState(() {
        lastVisiblePost = ds;
      });
    }
  }
}
