import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/explore/explore.dart';
import 'package:hs_connect/screens/home/post_feeds/domain_feed.dart';
import 'package:hs_connect/screens/home/post_feeds/home_feed.dart';
import 'package:hs_connect/screens/home/post_feeds/og_feed.dart';
import 'package:hs_connect/screens/home/profile/profile.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/screens/new_post/new_post.dart';

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
          backgroundColor: Colors.brown[50],
          appBar: AppBar(
            title: Text('HS Connect'),
            backgroundColor: Colors.brown[400],
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
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: const Icon(Icons.school, size: 18.0),
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: const Icon(Icons.add, size: 18.0),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewPost()),
                    );
                  },
                ),
                label: 'Post',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: const Icon(Icons.search_rounded, size: 18.0),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Explore()),
                    );
                  },
                ),
                label: 'Explore',
              ),
            ],
          ),
        ),
    );
  }
}
