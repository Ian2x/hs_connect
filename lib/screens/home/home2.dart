import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/post_feeds/domain_feed.dart';
import 'package:hs_connect/screens/home/post_feeds/home_feed.dart';
import 'package:hs_connect/screens/home/post_feeds/trending_feed.dart';
import 'package:hs_connect/screens/profile/profile.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/navbar.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/screens/profile/profile2.dart';

class Home2 extends StatefulWidget {
  const Home2({Key? key}) : super(key: key);

  @override
  _Home2State createState() => _Home2State();
}

class _Home2State extends State<Home2> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final AuthService _auth = AuthService();


  @override
  void initState() {

    _tabController = TabController(length: 3, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);

    if(userData==null || user==null) {
      return Loading();
    }
    // this sliver app bar is only use to hide/show the tabBar, the AppBar
    // is invisible at all times. The to the user visible AppBar is below
    return Scaffold(
      backgroundColor: HexColor("#E9EDF0"),
      body: Stack(
        children: <Widget>[
          NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[

                SliverAppBar(
                  elevation: 0.0,
                  primary: true,
                  floating: true,
                  backgroundColor: HexColor('FFFFFF'),//.withOpacity(0.3),
                  snap: true,
                  pinned: false,
                  bottom: TabBar(
                    tabs: [
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

                    controller: _tabController,
                  ),
                ),




              ];
            },
            body: TabBarView(
              children: [
                DomainFeed(),
                HomeFeed(),
                userData!=null ? TrendingFeed(country: userData.country, state: userData.state, county: userData.county, domain: userData.domain) : Loading(),
              ],
              controller: _tabController,
              physics: new NeverScrollableScrollPhysics(),
            ),
          ),

          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              child: SafeArea(
                top: false,
                child: AppBar(
                  automaticallyImplyLeading: true,
                  elevation: 0,
                  title: Text('HS Connect',
                      style:
                      TextStyle(
                        color: Colors.black,
                      )
                  ),
                  backgroundColor: HexColor("#FFFFFF"),
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
                              builder: (context) => profile2(profilePersonRef: userData.userRef)),
                        );
                      },
                    )
                  ],),
              ),
            ),
          ),



          // Here is the AppBar the user actually sees. The SliverAppBar
          // above will slide the TabBar underneath this one.
          // by using SafeArea it will.



        ],
      ),
      bottomNavigationBar: navbar(),
    );
  }

}
