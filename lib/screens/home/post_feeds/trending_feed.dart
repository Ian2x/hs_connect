import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/group_feed/suggested_groups.dart';
import 'package:hs_connect/screens/home/post_view/post_card2.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class TrendingFeed extends StatefulWidget {
  final String domain;
  final String? county;
  final String? state;
  final String? country;
  const TrendingFeed({Key? key, required this.domain, required this.county, required this.state, required this.country}) : super(key: key);

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
    GroupsDatabaseService _groups = GroupsDatabaseService();
    final refs = await _groups.getAllowableGroupRefs(domain: widget.domain, county: widget.county, state: widget.state, country: widget.country);
    setState(() {
      allowableGroupsRefs = refs;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (allowableGroupsRefs==null) {
      return Loading();
    }

    PostsDatabaseService _posts = PostsDatabaseService(groupRefs: allowableGroupsRefs);

    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);
    if (userData == null) {
      return Loading();
    }

    return StreamBuilder(
        stream: _posts.potentialTrendingPosts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Loading();
          } else {
            List<Post> posts = (snapshot.data as List<Post?>).map((post) => post!).toList();
            posts.sort((a,b)=>(b as Post).numComments-(a as Post).numComments);

            return ListView.builder(
              itemCount: posts.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                // when scroll up/down, fires once
                if (user==null) {
                  return Loading();
                } else return Center(
                    child: PostCard2(
                      postRef: posts[index].postRef,
                      userRef: posts[index].userRef,
                      groupRef: posts[index].groupRef,
                      title: posts[index].title,
                      text: posts[index].text,
                      media: posts[index].media,
                      createdAt: posts[index].createdAt,
                      likes: posts[index].likes,
                      dislikes: posts[index].dislikes,
                      currUserRef: userData.userRef,
                      numComments: posts[index].numComments,
                      reportedStatus: posts[index].reportedStatus,
                      tags: posts[index].tags,
                    )
                );
              },
            );
          }
        });
    // return SuggestedGroups(domain: userData.domain, county: userData.county, state: userData.state, country: userData.country);
  }
}
