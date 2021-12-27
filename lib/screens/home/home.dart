import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/search/group_search.dart';
import 'package:hs_connect/screens/home/post_feeds/domain_feed.dart';
import 'package:hs_connect/screens/home/post_feeds/home_feed.dart';
import 'package:hs_connect/screens/home/post_feeds/trending_feed.dart';
import 'package:hs_connect/screens/profile/profile.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/navbar.dart';
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

    if(userData==null || user==null) {
      return Loading();
    }
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
          backgroundColor: HexColor("#E9EDF0"),
          appBar: AppBar(
            title: Text('HS Connect',
              style:
                TextStyle(
                  color: Colors.black,
                )
            ),
            backgroundColor: HexColor("#FFFFFF"),
            elevation: 0.0,
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.person),
                label: Text('Logout',
                    style:
                    TextStyle(
                      color: Colors.black,
                    )
                ),
                onPressed: () async {
                  await _auth.signOut();
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.settings),
                label: Text('Profile',
                    style:
                    TextStyle(
                      color: Colors.black,
                    )
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile(profileId: user.uid)),
                  );
                },
              )
            ],
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Text(userData.domain,
                    style:
                    TextStyle(
                      color: Colors.black,
                    )
                  )
                ),
                Tab(
                  icon: Text("Home",
                      style:
                      TextStyle(
                        color: Colors.black,
                      )
                  )
                ),
                Tab(
                  icon: Text("Trending",
                      style:
                      TextStyle(
                        color: Colors.black,
                      )
                  )
                )
              ],
            )
          ),
          body: TabBarView(
            children: <Widget>[
              DomainFeed(),
              HomeFeed(),
              userData!=null ? TrendingFeed() : Loading(),
            ]
          ),
          bottomNavigationBar: navbar()
        ),
    );
  }
}
