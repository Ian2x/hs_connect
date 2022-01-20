import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/messages/allMessagesPage.dart';
import 'package:hs_connect/screens/activity/activityAppBar.dart';
import 'package:hs_connect/screens/activity/notifications/notificationsFeed.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
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
        appBar: activityAppBar(),
        body: Loading(),
        bottomNavigationBar: MyNavigationBar(
          currentIndex: 1,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: AppBar(
            backgroundColor: ThemeColor.white,
            elevation: 0.0,
            title: Row(
              children: <Widget>[
                SizedBox(width: 18.0),
                Column(
                  children: <Widget>[
                    SizedBox(height: 15),
                    Text('Activity',
                        style: TextStyle(
                            fontFamily: "Inter", fontSize: 24.0, color: ThemeColor.black, fontWeight: FontWeight.w600))
                  ],
                )
              ],
            ),
            bottom: TabBar(
              indicatorColor: Colors.transparent,
              labelColor: ThemeColor.black,
              unselectedLabelColor: ThemeColor.mediumGrey,
              labelStyle: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.normal,
              ),
              tabs: <Widget>[Tab(child: Text("Notifications")), Tab(child: Text("messages"))],
              controller: _tabController,
            ),
          ),
        ),
      ),
      body: Container(
        color: ThemeColor.backgroundGrey,
        child: TabBarView(children: <Widget>[
            NotificationsFeed(userData: userData),
            AllMessagesPage(userData: userData,)
          ], controller: _tabController, physics: BouncingScrollPhysics()),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 1,
      ),
    );
  }
}
