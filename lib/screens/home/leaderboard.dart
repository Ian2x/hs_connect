import 'package:flutter/material.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';

import '../../models/userData.dart';
import '../../shared/widgets/loading.dart';

class LeaderBoard extends StatefulWidget {
  final int userLikes;
  final UserData currUserData;

  const LeaderBoard({Key? key, required this.userLikes, required this.currUserData}) : super(key: key);

  @override
  _LeaderBoardState createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> with TickerProviderStateMixin {
  late TabController _tabController;
  List<OtherUserData>? schoolLeaders;
  List<OtherUserData>? globalLeaders;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getSchoolLeaders();
    getGlobalLeaders();
  }

  void getSchoolLeaders() async {
    schoolLeaders = await UserDataDatabaseService(currUserRef: widget.currUserData.userRef)
        .getLeaderboard(fromSchool: true, schoolDomain: widget.currUserData.domain);
  }

  void getGlobalLeaders() async {
    globalLeaders =
        await UserDataDatabaseService(currUserRef: widget.currUserData.userRef).getLeaderboard(fromSchool: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget leaderboardsTable(BuildContext context, bool fromSchool) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<OtherUserData>>(
        future: UserDataDatabaseService(currUserRef: widget.currUserData.userRef)
            .getLeaderboard(fromSchool: fromSchool, schoolDomain: widget.currUserData.domain),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            List<OtherUserData> localLeaders = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: localLeaders.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Container(padding: EdgeInsets.only(left: 0), child: Divider(height: 1, thickness: 1)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 13),
                      child: Row(children: [
                        SizedBox(width: 40, child: Text((index + 1).toString() + ".", style: textTheme.subtitle1)),
                        Text(localLeaders[index].fundamentalName, style: textTheme.subtitle1),
                        Spacer(),
                        Text(localLeaders[index].score.toString() + " likes", style: textTheme.subtitle1),
                      ]),
                    ),
                    index == localLeaders.length - 1
                        ? Container(padding: EdgeInsets.only(left: 0), child: Divider(height: 1, thickness: 1))
                        : Container()
                  ],
                );
              },
            );
          } else {
            return Loading();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: myBackButtonIcon(context),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Leaderboards",
                style: TextStyle(fontFamily: "Shippori", fontSize: 20),
              ),
              SizedBox(width: 50),
            ],
          ),
        ),
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  height: 35,
                  child: TabBar(
                    controller: _tabController,
                    padding: EdgeInsets.zero,
                    indicator: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(width: 2.0, color: widget.currUserData.domainColor ?? colorScheme.onSurface))),
                    indicatorPadding: EdgeInsets.only(bottom: 1),
                    indicatorWeight: 0.001,
                    labelStyle: textTheme.subtitle1?.copyWith(color: colorScheme.onSurface),
                    unselectedLabelStyle: textTheme.subtitle1?.copyWith(color: colorScheme.primary),
                    tabs: [
                      Tab(
                        icon: Text(widget.currUserData.fullDomainName ?? widget.currUserData.domain,
                            style: textTheme.headline6),
                      ),
                      Tab(
                        icon: Text("Global", style: textTheme.headline6),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    controller: _tabController,
                    children: [leaderboardsTable(context, true), leaderboardsTable(context, false)],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 17),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: widget.currUserData.domainColor ?? colorScheme.primary),
                      alignment: Alignment.center,
                      child: Text("Your likes: " + widget.userLikes.toString(),
                          style: textTheme.headline6?.copyWith(
                              color: colorScheme.brightness == Brightness.light
                                  ? colorScheme.surface
                                  : colorScheme.onSurface)),
                    ),
                  ],
                )
              ]),
            ),
            GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  if (details.delta.dx > 15) {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width)
            ),
          ],
        ));
  }
}
