
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/myStorageManager.dart';
import 'package:hs_connect/shared/tools/buildCircle.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';

class HomeAppBar extends SliverPersistentHeaderDelegate {
  static const tabBarHeight = 30.0;
  static const expandedHeight = 130.0;
  static const epsilon = 0.0001;

  final TabController tabController;
  final UserData userData;
  final bool isDomain;

  HomeAppBar({required this.tabController, required this.userData, required this.isDomain});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // shrink offset is 0 when fully open, 200 when closed
    final colorScheme = Theme.of(context).colorScheme;
    // opacity: shrinkOffset / expandedHeight,
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
            height: expandedHeight,
            padding: EdgeInsets.only(top: safeAreaHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Circles.",
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        ?.copyWith(fontSize: 21, fontWeight: FontWeight.w700)),
                SizedBox(height: 5),
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
                              gradient: isDomain ? Gradients.blueRed() : Gradients.solid(color: colorScheme.primary),
                              borderRadius: BorderRadius.circular(25)),
                          margin: EdgeInsets.fromLTRB(0,0,0,0),
                          padding: EdgeInsets.all(0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            margin: EdgeInsets.all(1.5),
                            padding: EdgeInsets.fromLTRB(34,3.5,34,3.5),
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
                              gradient: !isDomain ? Gradients.blueRed() : Gradients.solid(color: colorScheme.primary),
                              borderRadius: BorderRadius.circular(25)),
                          margin: EdgeInsets.fromLTRB(0,0,0,0),
                          padding: EdgeInsets.all(0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            margin: EdgeInsets.all(1.5),
                            padding: EdgeInsets.fromLTRB(34,3.5,34,3.5),
                            child: Text("Public",
                                style: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500, fontSize: 15, color: !isDomain ? colorScheme.onSurface : colorScheme.primary),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis),
                          ),
                        )),
                  ],
                ),
                //SizedBox(height: 100), // purposely larger than needed
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
  double get minExtent => 0; //kToolbarHeight + tabBarHeight+21.2;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

