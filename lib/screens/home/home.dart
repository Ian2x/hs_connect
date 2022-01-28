import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/new/floatingNewButton.dart';
import 'package:hs_connect/screens/home/postFeed/domainFeed.dart';
import 'package:hs_connect/screens/home/postFeed/trendingFeed.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

import 'mySliverAppBar.dart';

class Home extends StatefulWidget {
  final UserData userData;
  const Home({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isDomain = true;
  late TabController tabController;
  var top = 0.0;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (mounted) {
        setState(() {
          isDomain = tabController.index == 0;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print(MediaQuery.of(context).padding.top + kToolbarHeight);
    final userData = Provider.of<UserData?>(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (userData == null) {
      return Scaffold(backgroundColor: colorScheme.background, body: Loading());
    }
    // this sliver app bar is only use to hide/show the tabBar, the AppBar
    // is invisible at all times. The to the user visible AppBar is below
    return Scaffold(
      backgroundColor: colorScheme.background,
      //extendBody: true,
      //extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              print('something');
              return [
                SliverPersistentHeader(
                  delegate: MySliverAppBar(tabController: tabController, userData: userData, isDomain: isDomain),
                  pinned: true,
                  floating: true,
                )
              ];
            },
            body: TabBarView(
              children: [
                DomainFeed(currUser: userData),
                TrendingFeed(currUser: userData),
              ],
              controller: tabController,
              physics: new NeverScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyNavigationBar(currentIndex: 0),
      floatingActionButton: floatingNewButton(context),
    );
  }
}
