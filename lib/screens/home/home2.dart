import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/home/postFeed/domainFeed.dart';
import 'package:hs_connect/screens/home/postFeed/trendingFeed.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

import 'new/floatingNewButton.dart';

class Home2 extends StatefulWidget {
  final UserData userData;

  const Home2({Key? key, required this.userData}) : super(key: key);

  @override
  _Home2State createState() => _Home2State();
}

class _Home2State extends State<Home2> with SingleTickerProviderStateMixin {
  bool isDomain = true;

  String? groupImageString;
  Image? groupImage;
  String? groupColor;
  late TabController _tabController;
  final scrollController = ScrollController();

  @override
  void initState() {
    getGroupData();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          isDomain = _tabController.index == 0;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.userData.userRef);
    final Group? fetchGroup =
        await _groups.groupFromRef(FirebaseFirestore.instance.collection(C.groups).doc(widget.userData.domain));
    if (mounted) {
      setState(() {
        if (fetchGroup != null) {
          groupImageString = fetchGroup.image;
          groupColor = fetchGroup.hexColor;
          if (groupImageString != null && groupImageString != "") {
            var tempImage = Image.network(groupImageString!);
            tempImage.image
                .resolve(ImageConfiguration())
                .addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
              if (mounted) {
                setState(() => groupImage = tempImage);
              }
            }));
          }
        } else {
          groupImageString = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return Authenticate();
    }

    if (userData == null) {
      return Scaffold(backgroundColor: colorScheme.background, body: Loading());
    }

    String fullDomainName = userData.fullDomainName != null ? userData.fullDomainName! : userData.domain;
    return Scaffold(
        bottomNavigationBar: MyNavigationBar(currentIndex: 0),
        floatingActionButton: floatingNewButton(context),
        /*IconButton(
          onPressed: () {print(scrollController.position.atEdge  && scrollController.position.pixels != 0);print(scrollController.position.pixels);},
          icon: Icon(Icons.settings)
        ),*/
        body: NestedScrollView(
          floatHeaderSlivers: true,
          controller: scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                  backgroundColor: colorScheme.surface,
                  floating: true,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(0),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5,5,5,5),
                      margin: EdgeInsets.fromLTRB(0,0,0,7),
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      child:
                    Row(mainAxisSize: MainAxisSize.max, //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        SizedBox(width: 5),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Spacer(),
                        TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: isDomain
                                ? (userData.domainColor != null ? userData.domainColor : colorScheme.secondary) : colorScheme.primary
                          ),
                          padding: EdgeInsets.zero,
                          indicatorPadding: EdgeInsets.zero,
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorWeight: 0,
                          labelPadding: EdgeInsets.symmetric(horizontal: 5),
                          isScrollable: true,
                          tabs: [
                            Tab(
                              iconMargin: EdgeInsets.all(0),
                              child: Container(
                                //constraints: BoxConstraints(),
                                //color: Colors.green,
                                margin: EdgeInsets.all(0),
                                padding: isDomain ? EdgeInsets.fromLTRB(15, 5.5, 15, 0) : EdgeInsets.fromLTRB(15, 3.5, 15, 0),
                                constraints: BoxConstraints(maxWidth: 170),
                                height: 40,
                                decoration: isDomain ? null : BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  border:
                                      Border.all(color: isDomain ? Colors.transparent : colorScheme.onError, width: 2),
                                  color: isDomain
                                      ? (userData.domainColor != null ? userData.domainColor : colorScheme.secondary)
                                      : colorScheme.surface,
                                ),
                                child: Text(
                                  fullDomainName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      ?.copyWith(color: isDomain ? colorScheme.surface : colorScheme.primary),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                            Tab(
                                iconMargin: EdgeInsets.all(0),
                                child: Container(
                                  //constraints: BoxConstraints(),
                                  margin: EdgeInsets.all(0),
                                  padding: !isDomain ? EdgeInsets.fromLTRB(15, 5.5, 15, 0) : EdgeInsets.fromLTRB(15, 3.5, 15, 0),
                                  height: 40,
                                  decoration: !isDomain ? BoxDecoration() : BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    border: Border.all(
                                        color: !isDomain ? Colors.transparent : colorScheme.onError, width: 2),
                                    //color: !isDomain ? colorScheme.primary : colorScheme.surface,
                                  ),
                                  child: Text(
                                    "Trending",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        ?.copyWith(color: !isDomain ? colorScheme.surface : colorScheme.primary),
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                )),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.only(bottom: 5),
                          icon: Icon(Icons.settings, size: 25),
                          onPressed: () {},
                        ),
                        SizedBox(width: 5),
                      ]),
                    ),
                  ))
            ];
          },
          body: TabBarView(
            children: [
              DomainFeed(currUser: userData),
              TrendingFeed(currUser: userData),
            ],
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
          ),
        )
    );
  } //Build

}
