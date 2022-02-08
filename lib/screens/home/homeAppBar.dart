import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/searchSelectionSheet.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';


class HomeAppBar extends SliverPersistentHeaderDelegate{
  static const tabBarHeight = 40.0;
  static const expandedHeight = 130.0;
  static const tabBarPadding = EdgeInsets.symmetric(horizontal: 25);

  final TabController tabController;
  final UserData userData;
  final bool isDomain;
  final bool searchByTrending;
  final VoidFunction toggleSearch;
  final double hp;

  HomeAppBar({required this.tabController, required this.userData, required this.isDomain, required this.searchByTrending, required this.hp, required this.toggleSearch});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // shrink offset is 0 when fully open, 200 when closed
    final colorScheme = Theme.of(context).colorScheme;
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final safeAreaHeight = MediaQuery.of(context).padding.top;
    final fullDomainName = userData.fullDomainName != null ? userData.fullDomainName! : userData.domain;
    return Stack(
      children: [
        Positioned(
          top: - shrinkOffset,
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
                    SizedBox(height: 3*hp),
                    GestureDetector(
                      onTap: () async => await AuthService().signOut(),
                      child: Text("circles.co",
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              ?.copyWith(fontSize: 18*hp, fontWeight: FontWeight.bold)),
                    ),
                    TabBar(
                      controller: tabController,
                      padding: EdgeInsets.zero,
                      indicatorColor: colorScheme.onSurface,
                      indicator: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1.5*hp, color: colorScheme.onSurface)
                        )
                      ),
                      indicatorPadding: tabBarPadding,
                      indicatorWeight: 0.001*hp,
                      labelStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500, fontSize: 15, color: colorScheme.onSurface),
                      unselectedLabelStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500, fontSize: 15, color: colorScheme.primary),
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
                            )
                        ),
                        Tab(
                            iconMargin: EdgeInsets.only(),
                            height: tabBarHeight,
                            child: Container(
                              padding: tabBarPadding,
                              child: Text(C.Public,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis),
                            )),
                      ],
                    ),
                  ],
                ),
                Positioned(
                    left: 333*wp,
                    top: 5*hp,
                    child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20*hp),
                                  )),
                              builder: (context) => pixelProvider(context, child: SearchSelectionSheet(initialSearchByTrending: searchByTrending, toggleSearch: toggleSearch)));
                        },
                        child: Row(children: [Icon(Icons.sort_rounded, size: 20*hp), SizedBox(width: 3*wp), Text(searchByTrending ? 'Hot' : 'New', style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: 13*hp))])))
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight*hp;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

