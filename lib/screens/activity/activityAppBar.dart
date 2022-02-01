import 'package:flutter/material.dart';
import 'package:hs_connect/screens/home/homeAppBar.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';

PreferredSizeWidget activityAppBar({required BuildContext context, required bool isNotifications, required TabController tabController}) {
  final wp = Provider.of<WidthPixel>(context).value;
  final hp = Provider.of<HeightPixel>(context).value;
  final colorScheme = Theme.of(context).colorScheme;

  final safeAreaHeight = MediaQuery.of(context).padding.top;
  final temp = HomeAppBar.expandedHeight - safeAreaHeight;


  return PreferredSize(
    preferredSize: Size.fromHeight(temp),
    child: Container(
      padding: EdgeInsets.only(top: safeAreaHeight),
      color: colorScheme.surface,
      child: Column(
        children: [
          Spacer(),
          Row(
            children: <Widget>[
              SizedBox(width: 18*wp),
              Column(
                children: <Widget>[
                  SizedBox(height: 15*hp),
                  Text('Activity',
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          ?.copyWith(fontSize: 24, color: colorScheme.primaryVariant, fontWeight: FontWeight.w600, letterSpacing: 1))
                ],
              )
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.only(right: 15, left: 15),
            child: TabBar(
              controller: tabController,
              padding: EdgeInsets.zero,
              indicatorWeight: HomeAppBar.epsilon,
              tabs: <Widget>[
                Tab(
                    iconMargin: EdgeInsets.only(),
                    height: HomeAppBar.tabBarHeight,
                    icon: Column(children: <Widget>[
                      GradientText('Notifications',
                          style: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          gradient: isNotifications ? Gradients.blueRed() : Gradients.solid(color: colorScheme.primary)),
                      Spacer(),
                      isNotifications
                          ? Container(
                        height: topGradientThickness,
                        decoration: BoxDecoration(gradient: Gradients.blueRed()),
                      )
                          : Container()
                    ])),
                Tab(
                    iconMargin: EdgeInsets.only(),
                    height: HomeAppBar.tabBarHeight,
                    icon: Column(children: <Widget>[
                      GradientText("Messages",
                          style: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          gradient: !isNotifications ? Gradients.blueRed() : Gradients.solid(color: colorScheme.primary)),
                      //Text("Trending", style: Theme.of(context).textTheme.subtitle1),
                      Spacer(),
                      !isNotifications
                          ? Container(
                        height: topGradientThickness,
                        decoration: BoxDecoration(gradient: Gradients.blueRed()),
                      )
                          : Container()
                    ]))
              ],
            ),
          ),
        ]
      ),
    )

  );
}
