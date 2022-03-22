import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/searchSelectionSheet.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

class HomeAppBar extends SliverPersistentHeaderDelegate {
  static const expandedHeight = 50.0;

  final UserData currUserData;
  final bool isDomain;
  final bool searchByTrending;
  final VoidBoolParamFunction toggleSearch;
  final double safeAreaHeight;
  final VoidFunction toggleFeed;

  HomeAppBar(
      {required this.currUserData,
      required this.isDomain,
      required this.searchByTrending,
      required this.toggleSearch,
      required this.safeAreaHeight,
      required this.toggleFeed});

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
            padding: EdgeInsets.only(top: safeAreaHeight),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(15,13,0,50),
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Text("Convo",
                          style: TextStyle(fontFamily: "Shippori", fontSize: 20),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Positioned(
                    right: 15,
                    top: 14,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 2, 10, 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: currUserData.domainColor ?? colorScheme.primary
                      ),
                      child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                )),
                                builder: (context) => SearchSelectionSheet(
                                    initialSearchByTrending: searchByTrending, toggleSearch: toggleSearch));
                          },
                          child: Row(
                            children: [
                              Text(searchByTrending ? "Hottest" : "Newest", style: textTheme.headline6?.copyWith(fontSize: 17, color: colorScheme.brightness == Brightness.light ? colorScheme.surface : colorScheme.onSurface)),
                              SizedBox(width: 5),
                              Icon(Icons.sort_rounded, size: 22, color: colorScheme.brightness == Brightness.light ? colorScheme.surface : colorScheme.onSurface),
                            ],
                          )),
                    ))
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
