import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profilePostFeed.dart';
import 'package:hs_connect/screens/profile/profileWidgets/newMessageButton.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';

class ProfileBody extends StatefulWidget {
  final DocumentReference profileUserRef;
  final UserData currUserData;

  ProfileBody({Key? key, required this.profileUserRef, required this.currUserData}) : super(key: key);

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  UserData? profileData;
  String? domainImage;


  void getProfileUserData() async {
    UserData? fetchUserData;
    if (widget.profileUserRef!=widget.currUserData.userRef) {
      // get other profile data
      UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserData.userRef);
      fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.profileUserRef);
    } else {
      // use own profile data
      fetchUserData = widget.currUserData;
    }
    if (fetchUserData != null && mounted) {
      setState(() {
        profileData = fetchUserData;
        /*profileUsername = fetchUserData!.displayedName;
        profileScore = fetchUserData.score;
        profileImageURL = fetchUserData.profileImageURL;
        domainColor = fetchUserData.domainColor;
        domainName = fetchUserData.fullDomainName != null ? fetchUserData.fullDomainName! : fetchUserData.domain;*/
      });
    }
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserData.userRef);
    if (fetchUserData != null) {
      var fetchUserDomain = await _groups.getGroup(FirebaseFirestore.instance.collection(C.groups).doc(fetchUserData.domain));
      if (fetchUserDomain != null && mounted) {
        setState(() {
          domainImage = fetchUserDomain.image;
        });
      }
    }
  }

  @override
  void initState() {
    getProfileUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    if (profileData==null) return Loading();

    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        SizedBox(height:98*hp),
        ProfileImage(
          profileImageURL: profileData!.profileImageURL,
          currUserName: profileData!.displayedName,
          showEditIcon: widget.profileUserRef == widget.currUserData.userRef && userData != null && widget.currUserData.userRef == userData.userRef,
        ),
        SizedBox(height: 10*hp),
        Text(
          profileData!.displayedName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5,
        ),
        SizedBox(height: 10*hp),
        Row(
          children: [
            Spacer(),
            Container(
              height: 60*hp,
              child: GroupTag(groupImageURL: domainImage, groupName: profileData!.fullDomainName!=null ? profileData!.fullDomainName! : profileData!.domain,
                  fontSize: 18*hp, groupColor: profileData!.domainColor != null ? profileData!.domainColor!:
                      null,
              ),
            ),
            SizedBox(width:20*wp),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: profileData!.score.toString(),
                      style: Theme.of(context).textTheme.headline6),
                  TextSpan(text: " Likes ",
                      style: Theme.of(context).textTheme.headline6),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
        widget.profileUserRef != widget.currUserData.userRef
            ? Column(
                children: <Widget>[
                  SizedBox(height: 78*hp),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                    SizedBox(width: 45*wp),
                    NewMessageButton(
                      otherUserData: profileData!,
                      currUserRef: widget.currUserData.userRef,
                    )
                  ])
                ],
              )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            SizedBox(height: 78*hp),
            ProfilePostFeed(profUserRef: widget.profileUserRef),
          ]
        )
      ],
    );
  }
}
