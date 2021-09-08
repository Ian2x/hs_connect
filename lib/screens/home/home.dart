import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/Backend/models/user_data.dart';
import 'package:hs_connect/Backend/screens/explore/explore.dart';
import 'package:hs_connect/Backend/screens/home/post_feeds/domain_feed.dart';
import 'package:hs_connect/Backend/screens/home/post_feeds/home_feed.dart';
import 'package:hs_connect/Backend/screens/home/post_feeds/og_feed.dart';
import 'package:hs_connect/Backend/screens/home/profile/profile.dart';
import 'package:hs_connect/Backend/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/Tools/HexColor.dart';
import 'package:hs_connect/Widgets/OGnavbar.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);

    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        backgroundColor: HexColor("#121212"),
          appBar: AppBar(
            title: Text('HS Connect'),
            backgroundColor: HexColor("#121212"),
            elevation: 0.0,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.person),
                label: Text('Logout'),
                onPressed: () async {
                  await _auth.signOut();
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.settings),
                label: Text('Profile'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile(profileId: user!.uid)),
                  );
                },
              )
            ],
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  text: userData != null ? userData.domain : 'domain',
                ),
                Tab(
                  text: 'Home'
                ),
                Tab(
                  text: 'Trending'
                )
              ],
            )
          ),

          body: TabBarView(
            children: <Widget>[
              DomainFeed(),
              HomeFeed(),
              Container(),
            ]
          ),

          bottomNavigationBar: OGnavbar(),
        ),
    );
  }
}
