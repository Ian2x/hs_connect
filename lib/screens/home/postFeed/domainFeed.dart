import 'dart:ui';

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
  final ScrollController parentScrollController;

  const DomainFeed({Key? key, required this.currUser,
  required this.parentScrollController}) : super(key: key);

  @override
  _DomainFeedState createState() => _DomainFeedState();
}

class _DomainFeedState extends State<DomainFeed> {

  List<Post> posts = [];
  DocumentSnapshot? lastVisiblePost;

  late PostsDatabaseService _posts;

  @override
  void initState() {
    _posts = PostsDatabaseService(currUserRef: widget.currUser.userRef);
    getInitialPosts();
    widget.parentScrollController.addListener(() {
      if (widget.parentScrollController.position.atEdge) {
        if (widget.parentScrollController.position.pixels != 0) {
          getNextPosts();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    return RefreshIndicator(
        child: postsListView(posts: posts, currUserRef: userData.userRef),
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
