import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:provider/provider.dart';

class TrendingFeed extends StatefulWidget {
  const TrendingFeed({Key? key}) : super(key: key);

  @override
  _TrendingFeedState createState() => _TrendingFeedState();
}

class _TrendingFeedState extends State<TrendingFeed> {

  @override
  Widget build(BuildContext context) {


    GroupsDatabaseService _groups = GroupsDatabaseService();
    final userData = Provider.of<UserData?>(context);

    if(userData==null) {
      return Loading();
    } else {
      return TextButton.icon(
        icon: Icon(Icons.settings),
        label: Text('Test button'),
        onPressed: () {
          _groups.getTrendingGroups(domain: userData.domain, county: userData.county, state: userData.state, country: userData.country);
        },
      );
    }
  }
}
