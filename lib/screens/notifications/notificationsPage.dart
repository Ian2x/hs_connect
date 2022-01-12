import 'package:flutter/material.dart';
import 'package:hs_connect/screens/notifications/notificationsAppBar.dart';
import 'package:hs_connect/screens/notifications/notificationsFeed.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: notificationsAppBar(),
      body: Column(children: <Widget>[
        TabBar(
          indicatorColor: ThemeColor.black,
          tabs: <Widget>[
            Tab(
                icon: Text("Posts & Comments",
                    style: TextStyle(
                      color: ThemeColor.black,
                      fontFamily: "Inter",
                    ))),
            Tab(
                icon: Text("Messages",
                    style: TextStyle(
                      color: ThemeColor.black,
                      fontFamily: "Inter",
                    )))
          ],
          controller: _tabController,
        ),
        SizedBox( // can be removed once tabbarview contains listviewbuilders
          height: 500.0,
          child: TabBarView(children: <Widget>[
            NotificationsFeed(),
            Container(height: 100.0, child: Text("bye"))
          ], controller: _tabController, physics: BouncingScrollPhysics()),
        )
      ]),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 2,
      ),
    );
  }
}
