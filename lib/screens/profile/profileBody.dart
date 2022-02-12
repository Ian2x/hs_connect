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
    if (widget.profileUserRef != widget.currUserData.userRef) {
      // get other profile data
      UserDataDatabaseService _userInfoDatabaseService =
          UserDataDatabaseService(currUserRef: widget.currUserData.userRef);
      fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.profileUserRef);
    } else {
      // use own profile data
      fetchUserData = widget.currUserData;
    }
    if (fetchUserData != null && mounted) {
      setState(() {
        profileData = fetchUserData;
      });
    }
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserData.userRef);
    if (fetchUserData != null) {
      var fetchUserDomain =
          await _groups.getGroup(FirebaseFirestore.instance.collection(C.groups).doc(fetchUserData.domain));
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
    final colorScheme = Theme.of(context).colorScheme;




    if (profileData == null) return Loading();
    bool isOwnProfile = widget.profileUserRef == widget.currUserData.userRef &&
        userData != null &&
        widget.currUserData.userRef == userData.userRef;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          SizedBox(height: 20 * hp),
          ProfileImage(
            profileImageURL: profileData!.profileImageURL,
            currUserName: profileData!.fundamentalName,
            showEditIcon: isOwnProfile,
          ),
          SizedBox(height: 30 * hp),
          Text(
            profileData!.fundamentalName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight:FontWeight.w600),
          ),
          SizedBox(height: 14 * hp),
          Row(
            children: <Widget>[
              Spacer(),
              GroupTag(
                groupImageURL: profileData!.domainImage,
                groupName: profileData!.fullDomainName != null ? profileData!.fullDomainName! : profileData!.domain,
                borderRadius: 30*hp,
                padding: EdgeInsets.fromLTRB(30 * wp, 5 * hp, 30 * wp, 5 * hp),
                thickness: 1.5*hp,
                fontSize: 18*hp,
                groupColor: profileData!.domainColor!=null ? profileData!.domainColor! : null,
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 14 * hp),
          Center(
            child: Text(profileData!.score.toString() + " Likes", style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 17))
          ),
          widget.profileUserRef != widget.currUserData.userRef
              ? Column(
                  children: <Widget>[
                    SizedBox(height: 78 * hp),
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      SizedBox(width: 45 * wp),
                      NewMessageButton(
                        otherUserData: profileData!,
                        currUserData: widget.currUserData,
                      )
                    ])
                  ],
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  SizedBox(height: 40 * hp),
                  ProfilePostFeed(profileUserData: profileData!),
                ])
        ],
      ),
    );
  }
}
