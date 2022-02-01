import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/myStorageManager.dart';
import 'package:hs_connect/shared/tools/buildCircle.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';

class HomeAppBar extends SliverPersistentHeaderDelegate {
  static const tabBarHeight = 43.0;
  static const expandedHeight = 170.0;
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
      fit: StackFit.expand,
      children: [
        Container(
          padding: EdgeInsets.only(top: safeAreaHeight, right: 15, left: 15),
          width: MediaQuery.of(context).size.width,
          color: colorScheme.surface,
          child: Column(
            children: [
              Spacer(),
              TabBar(
                controller: tabController,
                padding: EdgeInsets.zero,
                indicatorWeight: epsilon,
                isScrollable: true,
                tabs: <Widget>[
                  Tab(
                      iconMargin: EdgeInsets.only(),
                      height: tabBarHeight,
                      icon: Container(
                        decoration: BoxDecoration(
                            gradient: isDomain ? Gradients.blueRed() : Gradients.solid(color: colorScheme.primary),
                            borderRadius: BorderRadius.circular(25)),
                        margin: EdgeInsets.fromLTRB(0,0,0,13),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          margin: EdgeInsets.all(1.5),
                          padding: EdgeInsets.fromLTRB(14,3.5,14,3.5),
                          child: GradientText(fullDomainName,
                              style: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              gradient: isDomain ? Gradients.blueRed() : Gradients.solid(color: colorScheme.primary)),
                        ),
                      )),
                  Tab(
                      iconMargin: EdgeInsets.only(),
                      height: tabBarHeight,
                      icon: Container(
                        decoration: BoxDecoration(
                          gradient: !isDomain ? Gradients.blueRed() : Gradients.solid(color: colorScheme.primary),
                          borderRadius: BorderRadius.circular(25)),
                        margin: EdgeInsets.fromLTRB(0,0,0,13),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          margin: EdgeInsets.all(1.5),
                          padding: EdgeInsets.fromLTRB(14,3.5,14,3.5),
                          child: GradientText("Public",
                              style: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              gradient: !isDomain ? Gradients.blueRed() : Gradients.solid(color: colorScheme.primary)),
                        ),
                      ))
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: safeAreaHeight - shrinkOffset + 10,
          left: 10,
          child: Opacity(
            opacity: (1 - shrinkOffset / expandedHeight),
            child: Card(
              elevation: 0,
              color: colorScheme.surface,
              child: Row(
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: isDomain
                          ? buildGroupCircle(
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: ImageStorage().groupImageProvider(userData.domainImage))),
                              ),
                              all: 2.0,
                              backgroundColor: colorScheme.surface)
                          : buildGroupCircle(
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(image: AssetImage('assets/logo1background.png'))),
                              ),
                              all: 2.0,
                              backgroundColor: colorScheme.surface)
                      /*Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: Gradients.blueRed(),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(2.5),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(image: AssetImage('assets/logo1background.png')))))*/
                      ),
                  SizedBox(width: 10),
                  Text("Circles",
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          ?.copyWith(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: 2.5)),
                  IconButton(
                      icon: Icon(Icons.height, size: 5),
                      onPressed: () {
                        print(MyStorageManager.readData('themeMode').then((value) {print(value);}));
                        //AuthService().signOut();
                      }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + tabBarHeight + 20;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
