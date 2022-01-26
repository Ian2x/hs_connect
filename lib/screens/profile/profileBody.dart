import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/profile/profilePostFeed.dart';
import 'package:hs_connect/screens/profile/profileWidgets/newMessageButton.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileName.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';

class ProfileBody extends StatefulWidget {
  final DocumentReference profileUserRef;
  final DocumentReference currUserRef;

  ProfileBody({Key? key, required this.profileUserRef, required this.currUserRef}) : super(key: key);

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  String profileUsername = '';

  String? profileImageURL;
  int profileScore = 0;
  String? domainImage;
  Color? domainColor;
  String domainName="";

  void getProfileUserData() async {
    UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    final UserData? fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.profileUserRef);
    if (fetchUserData != null && mounted) {
      setState(() {
        profileUsername = fetchUserData.displayedName;
        profileScore = fetchUserData.score;
        profileImageURL = fetchUserData.profileImageURL;
        domainColor = fetchUserData.domainColor;
        domainName = fetchUserData.fullDomainName != null ? fetchUserData.fullDomainName! : fetchUserData.domain;
      });
    }
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
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


    if (userData == null) {
      return Authenticate();
    }
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        SizedBox(height:98*hp),
        ProfileImage(
          profileImageURL: profileImageURL,
          currUserName: profileUsername,
          showEditIcon: widget.profileUserRef == widget.currUserRef && widget.currUserRef == userData.userRef,
        ),
        SizedBox(height: 10*hp),
        ProfileName(name: profileUsername, domain: userData.domain),
        SizedBox(height: 15*hp),
        Row(
          children: [
            Spacer(),
            GroupTag(groupImageURL: domainImage, groupName: domainName,
                fontSize: 18*hp, groupColor: domainColor != null ? domainColor!:
                    null,
            ),
            SizedBox(width:20*wp),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: profileScore.toString(),
                      style: Theme.of(context).textTheme.headline6),
                  TextSpan(text: " Likes ",
                      style: Theme.of(context).textTheme.headline6),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
        widget.profileUserRef != widget.currUserRef
            ? Column(
                children: <Widget>[
                  SizedBox(height: 78*hp),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                    SizedBox(width: 45*wp),
                    NewMessageButton(
                      otherUserRef: widget.profileUserRef,
                      currUserRef: widget.currUserRef,
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
