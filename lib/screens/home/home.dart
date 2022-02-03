
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postFeed/domainFeed.dart';
import 'package:hs_connect/screens/home/postFeed/publicFeed.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

import 'homeAppBar.dart';

class Home extends StatefulWidget {
  final UserData userData;
  const Home({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isDomain = true;
  late TabController tabController;
  ScrollController scrollController = ScrollController();
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
      scrollController.jumpTo(0);
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (userData == null) {
      return Scaffold(backgroundColor: colorScheme.background, body: Loading());
    }
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: <Widget>[
          NestedScrollView(
            floatHeaderSlivers: true,
            controller: scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverPersistentHeader(
                  delegate: HomeAppBar(tabController: tabController, userData: userData, isDomain: isDomain),
                  pinned: true,
                  floating: true,
                ),
              ];
            },
            body: TabBarView(
              children: [
                DomainFeed(currUser: userData, isDomain: isDomain),
                PublicFeed(currUser: userData, isDomain: isDomain),
              ],
              controller: tabController,
              physics: AlwaysScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyNavigationBar(currentIndex: 0),
    );
  }
}

