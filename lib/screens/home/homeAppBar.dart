import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/searchSelectionSheet.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

import '../../shared/widgets/buildGroupCircle.dart';

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
                GestureDetector(
                  onTap: toggleFeed,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15,13,0,50),
                    child: Row(
                      children: [
                        /*buildGroupCircle(
                            groupImage: isDomain ? currUserData.domainImage : null, size: 27, context: context, backgroundColor: colorScheme.surface),*/
                        SizedBox(width: 10),
                        Text(isDomain ? fullDomainName : "Public",
                            style: textTheme.headline6,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                ),
                Positioned(
                    right: 10,
                    top: 13,
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
                        child: Icon(Icons.sort_rounded, size: 25)))
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
