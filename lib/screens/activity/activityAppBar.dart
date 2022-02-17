import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/homeAppBar.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

PreferredSizeWidget activityAppBar({required BuildContext context, required bool isNotifications, required TabController tabController, required UserData userData}) {
  final wp = Provider.of<WidthPixel>(context).value;
  final hp = Provider.of<HeightPixel>(context).value;
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  final safeAreaHeight = MediaQuery.of(context).padding.top;


  return PreferredSize(
    preferredSize: Size.fromHeight(HomeAppBar.expandedHeight*hp + 0.5),
    child: Container(
      padding: EdgeInsets.only(top: safeAreaHeight),
      color: colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(30*wp, 4*hp, 30*wp, 0),
            child: Text('Activity',
                style: textTheme
                    .headline4
                    ?.copyWith(fontSize: 18*hp, fontWeight: FontWeight.w600))
          ),
          Spacer(),
          TabBar(
            controller: tabController,
            padding: EdgeInsets.zero,
            indicator: BoxDecoration(
                border: Border(bottom: BorderSide(width: 2.0*hp, color: userData.domainColor!=null ? userData.domainColor! : colorScheme.onSurface)
                )
            ),
            indicatorPadding: HomeAppBar.tabBarPadding,
            indicatorWeight: 0.001*hp,
            labelStyle: textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500, fontSize: 15, color: colorScheme.onSurface),
            unselectedLabelStyle: textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500, fontSize: 15, color: colorScheme.primary),
            tabs: <Widget>[
              Tab(
                  iconMargin: EdgeInsets.zero,
                  height: HomeAppBar.tabBarHeight,
                  child: Container(
                    padding: HomeAppBar.tabBarPadding,
                    child: Text('Notifications',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade),
                  )),
              Tab(
                  iconMargin: EdgeInsets.only(),
                  height: HomeAppBar.tabBarHeight,
                  icon: Container(
                    padding: HomeAppBar.tabBarPadding,
                    child: Text("Messages",
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade),
                  ))
            ],
          ),
        ]
      ),
    )

  );
}
