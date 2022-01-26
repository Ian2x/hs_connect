import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/activity/messages/allMessagesPage.dart';
import 'package:hs_connect/screens/activity/activityAppBar.dart';
import 'package:hs_connect/screens/activity/notifications/notificationsFeed.dart';
import 'package:hs_connect/shared/pixels.dart';
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    if (userData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: activityAppBar(context: context),
        body: Loading(),
        bottomNavigationBar: MyNavigationBar(
          currentIndex: 1,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100*hp),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            title: Row(
              children: <Widget>[
                SizedBox(width: 18*wp),
                Column(
                  children: <Widget>[
                    SizedBox(height: 15*hp),
                    Text('Activity',
                        style: Theme.of(context).textTheme.headline5)
                  ],
                )
              ],
            ),
            bottom: TabBar(
              indicatorColor: Colors.transparent,
              labelColor: colorScheme.onSurface,
              unselectedLabelColor: colorScheme.primary,
              labelStyle: Theme.of(context).textTheme.subtitle1,
              unselectedLabelStyle: Theme.of(context).textTheme.bodyText1,
              tabs: <Widget>[Tab(child: Text("Notifications")), Tab(child: Text("Messages"))],
              controller: _tabController,
            ),
          ),
        ),
      ),
      body: Container(
        color: colorScheme.background,
        child: TabBarView(children: <Widget>[
            NotificationsFeed(userData: userData),
            AllMessagesPage(userData: userData)
          ], controller: _tabController, physics: BouncingScrollPhysics()),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 1,
      ),
    );
  }
}
