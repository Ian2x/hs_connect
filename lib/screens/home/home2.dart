import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/home/postFeed/domainFeed.dart';
import 'package:hs_connect/screens/home/new/floatingNewButton.dart';
import 'package:hs_connect/screens/home/postFeed/trendingFeed.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

class Home2 extends StatefulWidget {

  final UserData userData;

  const Home2({Key? key, required this.userData}) : super(key: key);

  @override
  _Home2State createState() => _Home2State();
}

class _Home2State extends State<Home2> with SingleTickerProviderStateMixin {

  bool isDomain=true;

  String? groupImageString;
  Image? groupImage;
  String? groupColor;


  @override
  void initState() {
    getGroupData();
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



    Color pressedColor= ThemeColor.secondaryBlue;
    Color defaultColor= ThemeColor.mediumGrey;

    if (isDomain){
      groupColor != null ?
          pressedColor = HexColor(groupColor!): pressedColor = ThemeColor.secondaryBlue;
    } else {
      pressedColor= ThemeColor.secondaryBlue;
    }

    if(user==null) {
      return Authenticate();
    }

    if(userData==null) {
      return Scaffold(
          backgroundColor: ThemeColor.backgroundGrey,
          body: Loading()
      );
    }
    // this sliver app bar is only use to hide/show the tabBar, the AppBar
    // is invisible at all times. The to the user visible AppBar is below
    return Scaffold(
      body:
      ListView(
        children: [
          Column(
            children: [
              SizedBox(height:35),
              Row(
                children: [
                  SizedBox(width:20),
                  Container(
                    width: 35,
                    height: 35,
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
                  Text( isDomain != false ? userData.fullDomainName! : "Trending", style: ThemeText.inter(color: ThemeColor.black,
                    fontSize: 25, fontWeight: FontWeight.w700,
                  )),
                  Spacer(),
                  Icon(Icons.more_horiz),
                  SizedBox(width:20),
                ]   ,
              ),
              SizedBox(height:10),
              Row(  //Domain Button
                children: [
                  SizedBox(width:10),

                  InputChip(
                      padding: EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
                      side: BorderSide(
                        width: 2,
                        color: isDomain != false ? pressedColor: defaultColor,
                      ),
                      label: Text( widget.userData.fullDomainName!),
                      backgroundColor: isDomain != false ? pressedColor: ThemeColor.white,
                      labelStyle: ThemeText.inter(color: isDomain != false ?ThemeColor.white : defaultColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      onPressed: (){
                        setState(() {
                          isDomain=true;
                        });
                      },
                  ),
                  SizedBox(width:10),
                  InputChip(
                    padding: EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
                    side: BorderSide(
                      width: 2,
                      color: isDomain != false ? defaultColor: ThemeColor.secondaryBlue,
                    ),
                    label: Text( "Trending"),
                    backgroundColor: isDomain != false ? ThemeColor.white: ThemeColor.secondaryBlue,
                    labelStyle: ThemeText.inter(color: isDomain != false ?defaultColor : ThemeColor.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    onPressed: (){
                      setState(() {
                        isDomain=false;
                      });
                    },
                  ),
                  SizedBox(height:60),

                ],
              ),
              isDomain == false ? DomainFeed(currUser: userData)
                  :TrendingFeed(currUser: userData),
            ],
          ),

        ],
      ),
      bottomNavigationBar: MyNavigationBar(currentIndex: 0),
      floatingActionButton: floatingNewButton(context),
    );
  }

}
