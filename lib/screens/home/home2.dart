import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/home/postFeed/domainFeed.dart';
import 'package:hs_connect/screens/home/new/floatingNewButton.dart';
import 'package:hs_connect/screens/home/postFeed/trendingFeed.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'dart:ui' as ui;



class Home2 extends StatefulWidget {

  final UserData userData;

  const Home2({Key? key, required this.userData}) : super(key: key);

  @override
  _Home2State createState() => _Home2State();
}

class _Home2State extends State<Home2> with SingleTickerProviderStateMixin {

  var scrollController = ScrollController();
  bool isDomain=true;

  String? groupImageString;
  Image? groupImage;
  String? groupColor;
  late TabController _tabController;


  @override
  void initState() {
    getGroupData();
    _tabController = TabController(length: 2, vsync: this);


    super.initState();
  }

  void getGroupData() async {

    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.userData.userRef);
    final Group? fetchGroup = await _groups.groupFromRef(FirebaseFirestore.instance.collection(C.groups).doc(widget.userData.domain));
    if (mounted) {
      setState(() {
        if (fetchGroup!=null) {
          groupImageString = fetchGroup.image;
          groupColor= fetchGroup.hexColor;
          if (groupImageString != null && groupImageString!="") {
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



    Color pressedColor= colorScheme.secondary;
    Color defaultColor= colorScheme.primary;

    if (isDomain){
      if (groupColor!=null) {
        pressedColor = HexColor(groupColor!);
      }
    }

    if(user==null) {
      return Authenticate();
    }

    if(userData==null) {
      return Scaffold(
          backgroundColor: colorScheme.background,
          body: Loading()
      );
    }
    // this sliver app bar is only use to hide/show the tabBar, the AppBar
    // is invisible at all times. The to the user visible AppBar is below
    return Scaffold(
      bottomNavigationBar: MyNavigationBar(currentIndex: 0),
      floatingActionButton: floatingNewButton(context),
      body:
      Stack(
        children: [
          NestedScrollView(
          physics: ScrollPhysics(),
          floatHeaderSlivers: true,
          controller: scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget> [
            SliverAppBar(
              floating: true,
              pinned:true,
              snap:false,
              bottom:
                PreferredSize(
                  preferredSize: Size.fromHeight(100),
                  child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                  sigmaX: 5.0,
                  sigmaY: 5.0,
                  ),
                  child: TabBar(
                      padding: EdgeInsets.fromLTRB(40.0, 0.0, 10.0, 0.0),
                      controller: _tabController,
                      // give the indicator a decoration (color and border radius)
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          25.0,
                        ),
                        color: isDomain != false ? pressedColor: defaultColor,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      tabs: [
                        // first tab [you can add an icon using the icon property]
                        Tab(

                            child: TextButton(
                                onPressed: (){
                                  setState(() {
                                    isDomain=true;
                                    _tabController.animateTo((_tabController.index + 1) % 2);
                                  });
                                },
                                child: Text ( widget.userData.fullDomainName!,
                                    style: Theme.of(context).textTheme.subtitle1?.copyWith(color: isDomain != false ? colorScheme.surface : defaultColor)
                                )
                            )
                        ),
                        Tab(
                            child: TextButton(
                                onPressed: (){
                                  setState(() {
                                    isDomain=false;
                                    _tabController.animateTo((_tabController.index + 1) % 2);
                                  });
                                },
                                child: Text ("Trending",
                                    style: Theme.of(context).textTheme.subtitle1?.copyWith(color: isDomain != false ? defaultColor : colorScheme.surface))
                            )
                        ),
                      ],
                    )
                  ),
                ),
              toolbarHeight: 80,
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: groupImageString != null ?
                            NetworkImage(groupImageString!) : AssetImage("assets/me.png") as ImageProvider,
                          ),
                        ),
                      ),
                      SizedBox(width:20),
                      Text( isDomain != false ? userData.fullDomainName! : "Trending", style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Icons.settings, color: colorScheme.primary),
                      SizedBox(width:20),
                      ]   ,
                    ),
                  ],
                ),
              ),
              ];
            } ,
            body:
            TabBarView(
              children: [
                DomainFeed( currUser: userData, parentScrollController: scrollController,),
                TrendingFeed(currUser: userData),
              ],
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
            ),
            //header SliverBuilder

          ),
        ],
      ),//Nested ScrolLView
    );
  } //Build

}
