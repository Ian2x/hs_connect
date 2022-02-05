import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';


class HomeAppBar extends SliverPersistentHeaderDelegate{
  static const tabBarHeight = 30.0;
  static const expandedHeight = 135.0;
  static const epsilon = 0.0001;

  final TabController tabController;
  final UserData userData;
  final bool isDomain;

  HomeAppBar({required this.tabController, required this.userData, required this.isDomain});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // shrink offset is 0 when fully open, 200 when closed
    final colorScheme = Theme.of(context).colorScheme;
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final safeAreaHeight = MediaQuery.of(context).padding.top;
    final fullDomainName = userData.fullDomainName != null ? userData.fullDomainName! : userData.domain;
    return Stack(
      //fit: StackFit.expand,
      children: [
        Positioned(
          top: - shrinkOffset,
          left: 0,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: colorScheme.surface,
            //height: expandedHeight,
            padding: EdgeInsets.only(top: safeAreaHeight, bottom: 10*hp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: 3*hp),
                GestureDetector(
                  onTap: () async => await AuthService().signOut(),
                  child: Text("Circles.co",
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          ?.copyWith(fontSize: 24*hp, fontWeight: FontWeight.w700)),
                ),
                SizedBox(height: 12*hp),
                TabBar(
                  controller: tabController,
                  padding: EdgeInsets.zero,
                  indicatorWeight: epsilon,
                  isScrollable: true,
                  tabs: <Widget>[
                    Tab(
                        iconMargin: EdgeInsets.all(0),
                        height: tabBarHeight,
                        icon: Container(
                          decoration: BoxDecoration(
                              gradient: isDomain ? Gradients.blueRed() : null,
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(25*hp)),
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25*hp),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            margin: EdgeInsets.all(1.5*hp),
                            padding: EdgeInsets.fromLTRB(34*wp,3.5*hp,34*wp,3.5*hp),
                            child: Text(fullDomainName,
                                style: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500, fontSize: 15, color: isDomain ? colorScheme.onSurface : colorScheme.primary),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis),
                          ),
                        )
                    ),
                    Tab(
                        iconMargin: EdgeInsets.only(),
                        height: tabBarHeight,
                        icon: Container(
                          decoration: BoxDecoration(
                              gradient: !isDomain ? Gradients.blueRed() : null,
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(25*hp)),
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25*hp),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            margin: EdgeInsets.all(1.5*hp),
                            padding: EdgeInsets.fromLTRB(34*wp,3.5*hp,34*wp,3.5*hp),
                            child: Text("Public",
                                style: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500, fontSize: 15*hp, color: !isDomain ? colorScheme.onSurface : colorScheme.primary),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

