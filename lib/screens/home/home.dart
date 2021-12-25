import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/explore/explore.dart';
import 'package:hs_connect/screens/home/post_feeds/domain_feed.dart';
import 'package:hs_connect/screens/home/post_feeds/home_feed.dart';
import 'package:hs_connect/screens/home/post_feeds/og_feed.dart';
import 'package:hs_connect/screens/home/profile/profile.dart';
import 'package:hs_connect/services/auth.dart';
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
        backgroundColor: HexColor("#C4C4C4"),
          appBar: AppBar(
            backgroundColor: HexColor("#FFFFFF"),
            elevation: 0.0,
            title: Text('HS Connect',
                style:
                  TextStyle(
                    color: Colors.black,
                  )
            ),
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.person),
                label: Text('Logout',
                    style:
                      TextStyle(
                        color:Colors.black,
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
                      color:Colors.black,
                    )
                ),
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
                  icon: Text("Feed",
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
              Container(),
            ]
          ),

          bottomNavigationBar: OGnavbar(),
        ),
    );
  }
}
