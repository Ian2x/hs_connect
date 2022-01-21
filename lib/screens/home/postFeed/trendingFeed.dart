import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/postsListView.dart';
import 'package:provider/provider.dart';

class TrendingFeed extends StatefulWidget {
  final String domain;
  final String? county;
  final String? state;
  final String? country;
  final DocumentReference currUserRef;

  const TrendingFeed({Key? key, required this.domain, required this.county, required this.state, required this.country, required this.currUserRef})
      : super(key: key);

  @override
  _TrendingFeedState createState() => _TrendingFeedState();
}

class _TrendingFeedState extends State<TrendingFeed> {
  List<DocumentReference>? allowableGroupsRefs = null;

  @override
  void initState() {
    fetchAllowableGroupsRefs();
  }

  void fetchAllowableGroupsRefs() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final refs = await _groups.getAllowableGroupRefs(
        domain: widget.domain, county: widget.county, state: widget.state, country: widget.country);
    if (mounted) {
      setState(() {
        allowableGroupsRefs = refs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData?>(context);

    if (userData == null || allowableGroupsRefs == null) return Loading();

    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: userData.userRef, groupRefs: allowableGroupsRefs);
    return StreamBuilder(
        stream: _posts.potentialTrendingPosts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Loading();
          } else {
            List<Post?> postss = (snapshot.data as List<Post?>);
            postss.removeWhere((value) => value == null);
            List<Post> posts = postss.map((item) => item!).toList();
            
            posts.sort((a, b) {
              final int val = (2 * b.numComments + 2 * b.numReplies + b.likes.length + b.dislikes.length) - (2 * a.numComments + 2 * a.numReplies + a.likes.length + a.dislikes.length);
              if (val!=0) {
                return val;
              } else {
                return b.createdAt.compareTo(a.createdAt);
              }
            });

            return postsListView(posts: posts, currUserRef: userData.userRef);
          }
        });
  }
}
