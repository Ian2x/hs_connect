import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/searchSelectionSheet.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

class HomeAppBar extends SliverPersistentHeaderDelegate {
  static const tabBarHeight = 40.0;
  static const expandedHeight = 69.0;

  static const tabBarPadding = EdgeInsets.symmetric(horizontal: 25);

  final TabController tabController;
  final UserData currUserData;
  final bool isDomain;
  final bool searchByTrending;
  final VoidBoolParamFunction toggleSearch;
  final double safeAreaHeight;

  HomeAppBar(
      {required this.tabController,
      required this.currUserData,
      required this.isDomain,
      required this.searchByTrending,
      required this.toggleSearch,
      required this.safeAreaHeight});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // shrink offset is 0 when fully open, 200 when closed
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    //final safeAreaHeight = MediaQuery.of(context).padding.top;
    final fullDomainName = currUserData.fullDomainName ?? currUserData.domain;
    return Stack(
      children: [
        Positioned(
          top: -shrinkOffset,
          left: 0,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: colorScheme.surface,
            //height: expandedHeight,
            padding: EdgeInsets.only(top: safeAreaHeight),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 3),
                    GestureDetector(
                      child: Text("convo",
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: "Shippori")),
                    ),
                    TabBar(
                      controller: tabController,
                      padding: EdgeInsets.zero,
                      indicator: BoxDecoration(
                          border: Border(
                        bottom: BorderSide(
                            width: 2.5,
                            color:
                                currUserData.domainColor ?? colorScheme.onSurface),
                      )),
                      indicatorPadding: tabBarPadding,
                      indicatorWeight: 0.001,
                      labelStyle: textTheme.subtitle2
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.onSurface),
                      unselectedLabelStyle: Theme.of(context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.primary),
                      tabs: <Widget>[
                        Tab(
                            iconMargin: EdgeInsets.zero,
                            height: tabBarHeight,
                            child: Container(
                              padding: tabBarPadding,
                              child: Text(fullDomainName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis),
                            )),
                        Tab(
                            iconMargin: EdgeInsets.only(),
                            height: tabBarHeight,
                            child: Container(
                              padding: tabBarPadding,
                              child: Text(C.Public,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis),
                            )),
                      ],
                    ),
                  ],
                ),
                Positioned(
                    right: 10,
                    top: 5,
                    child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              )),
                              builder: (context) => SearchSelectionSheet(
                                  initialSearchByTrending: searchByTrending, toggleSearch: toggleSearch));
                        },
                        child: Row(children: [
                          Icon(Icons.sort_rounded, size: 20),
                          SizedBox(width: 3),
                          Text(searchByTrending ? 'Hot' : 'New',
                              style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: 13))
                        ])))
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight + safeAreaHeight;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
