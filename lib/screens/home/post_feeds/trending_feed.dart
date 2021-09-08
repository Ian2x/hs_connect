import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/group_feed/trending_groups_feed.dart';
import 'package:hs_connect/screens/home/post_view/post_card.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:provider/provider.dart';

class TrendingFeed extends StatefulWidget {
  const TrendingFeed({Key? key}) : super(key: key);

  @override
  _TrendingFeedState createState() => _TrendingFeedState();
}

class _TrendingFeedState extends State<TrendingFeed> {
  String groupId = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData?>(context);
    if (userData == null) return Loading();
    return TrendingGroupsFeed(domain: userData.domain, county: userData.county, state: userData.state, country: userData.country);
  }
}
