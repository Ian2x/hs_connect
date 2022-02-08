import 'package:flutter/material.dart';
import 'package:hs_connect/screens/home/homeAppBar.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

PreferredSizeWidget activityAppBar({required BuildContext context, required bool isNotifications, required TabController tabController}) {
  final wp = Provider.of<WidthPixel>(context).value;
  final hp = Provider.of<HeightPixel>(context).value;
  final colorScheme = Theme.of(context).colorScheme;

  final safeAreaHeight = MediaQuery.of(context).padding.top;


  return PreferredSize(
    preferredSize: Size.fromHeight(HomeAppBar.expandedHeight*hp-safeAreaHeight),
    child: Container(
      padding: EdgeInsets.only(top: safeAreaHeight),
      color: colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(30*wp, 4*hp, 30*wp, 0),
            child: Text('Activity',
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(fontSize: 18*hp, fontWeight: FontWeight.w600))
          ),
          Spacer(),
          TabBar(
            controller: tabController,
            padding: EdgeInsets.zero,
            indicatorColor: colorScheme.onSurface,
            indicator: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1.5*hp, color: colorScheme.onSurface)
                )
            ),
            indicatorPadding: HomeAppBar.tabBarPadding,
            indicatorWeight: 0.001*hp,
            labelStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500, fontSize: 15, color: colorScheme.onSurface),
            unselectedLabelStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500, fontSize: 15, color: colorScheme.primary),
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
