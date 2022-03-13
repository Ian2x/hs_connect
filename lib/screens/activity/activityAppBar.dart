import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';

PreferredSizeWidget activityAppBar(
    {required BuildContext context,
    required TabController tabController,
    required UserData currUserData}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  final safeAreaHeight = MediaQuery.of(context).padding.top;

  return PreferredSize(
      preferredSize: Size.fromHeight(68.1),
      child: Container(
        padding: EdgeInsets.only(top: safeAreaHeight),
        color: colorScheme.surface,
        child: Column(children: [
          Container(
              padding: EdgeInsets.fromLTRB(30, 4, 30, 0),
              child: Text('Activity', style: textTheme.headline6)),
          Spacer(),
          TabBar(
            controller: tabController,
            padding: EdgeInsets.zero,
            indicator: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: 2.0,
                        color: currUserData.domainColor ?? colorScheme.onSurface))),
            indicatorPadding: EdgeInsets.only(bottom: 1),
            indicatorWeight: 0.001,
            labelStyle:
                textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            unselectedLabelStyle:
                textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
            tabs: <Widget>[
              Tab(
                  iconMargin: EdgeInsets.zero,
                  height: 40,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 1),
                    child: Text('Notifications', maxLines: 1, softWrap: false, overflow: TextOverflow.fade),
                  )),
              Tab(
                  iconMargin: EdgeInsets.only(),
                  height: 40,
                  icon: Container(
                    padding: EdgeInsets.only(bottom: 1),
                    child: Text("Messages", maxLines: 1, softWrap: false, overflow: TextOverflow.fade),
                  ))
            ],
          ),
        ]),
      ));
}
