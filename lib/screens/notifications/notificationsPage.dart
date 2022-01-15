import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/notifications/Messages/allMessagesPage.dart';
import 'package:hs_connect/screens/notifications/notificationsAppBar.dart';
import 'package:hs_connect/screens/notifications/notificationsFeed.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: notificationsAppBar(),
        body: Loading(),
        bottomNavigationBar: MyNavigationBar(
          currentIndex: 1,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: notificationsAppBar(),
      body: Container(
        color: ThemeColor.backgroundGrey,
        child: Column(children: <Widget>[
          Container(
            color: ThemeColor.white,
            child: TabBar(
              indicatorColor: Colors.transparent,
              labelColor: ThemeColor.black,
              unselectedLabelColor: ThemeColor.mediumGrey,
              labelStyle: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w700
              ),
              tabs: <Widget>[
                Tab(child: Text("Posts & Comments")),
                Tab(child: Text("Messages"))
              ],
              controller: _tabController,
            ),
          ),
          SizedBox( // can be removed once tabbarview contains listviewbuilders
            height: 500.0,
            child: TabBarView(children: <Widget>[
              NotificationsFeed(),
              AllMessagesPage(userData: userData,)
            ], controller: _tabController, physics: BouncingScrollPhysics()),
          )
        ]),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 1,
      ),
    );
  }
}
