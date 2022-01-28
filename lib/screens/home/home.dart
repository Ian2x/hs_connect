import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postFeed/domainFeed.dart';
import 'package:hs_connect/screens/home/new/floatingNewButton.dart';
import 'package:hs_connect/screens/home/postFeed/domainFeed2.dart';
import 'package:hs_connect/screens/home/postFeed/trendingFeed.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {


  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final AuthService _auth = AuthService();


  @override
  void initState() {

    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    final userData = Provider.of<UserData?>(context);
    final colorScheme = Theme.of(context).colorScheme;

    if(userData==null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: Loading()
      );
    }
    // this sliver app bar is only use to hide/show the tabBar, the AppBar
    // is invisible at all times. The to the user visible AppBar is below
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: <Widget>[
          NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  elevation: 0,
                  primary: true,
                  floating: true,
                  backgroundColor: colorScheme.surface,
                  snap: true,
                  pinned: false,
                  bottom: TabBar(
                    indicatorColor: colorScheme.primaryVariant,
                    tabs: <Widget>[
                      Tab(
                          icon: Text(userData.fullDomainName!=null ? userData.fullDomainName! : userData.domain,
                              style:
                              Theme.of(context).textTheme.subtitle2
                          )
                      ),
                      Tab(
                          icon: Text("Trending",
                              style:
                              Theme.of(context).textTheme.subtitle2
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
                DomainFeed2(currUser: userData),
                TrendingFeed(currUser: userData),
              ],
              controller: _tabController,
              physics: new NeverScrollableScrollPhysics(),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              child: SafeArea(
                top: false,
                child: AppBar(
                  automaticallyImplyLeading: true,
                  elevation: 0,
                  title: Text('HS Connect',
                      style:
                      Theme.of(context).textTheme.headline6
                  ),
                  backgroundColor: colorScheme.surface,
                  actions: <Widget>[
                    TextButton.icon(
                      icon: Icon(Icons.person),
                      label: Text('Logout',
                          style:
                          Theme.of(context).textTheme.headline6
                      ),
                      onPressed: () async {
                        await _auth.signOut();
                      },
                    ),
                  ],),
              ),
            ),
          ),

        ],
      ),
      bottomNavigationBar: MyNavigationBar(currentIndex: 0),
      floatingActionButton: floatingNewButton(context),
    );
  }

}
