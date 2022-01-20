import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/profile/profileWidgets/newMessageButton.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileName.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileStats.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';

class ProfileBody extends StatefulWidget {
  final DocumentReference profileRef;
  final DocumentReference currUserRef;

  ProfileBody({Key? key, required this.profileRef, required this.currUserRef}) : super(key: key);

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  String profileUsername = '';

  bool profileImageExists = false;
  Widget? profileImage = Loading(size: 30.0);
  String? profileImageURL;
  int profileScore = 0;
  String? userGroupString;
  Color? userGroupColor;
  String userGroup="";

  void getProfileUserData() async {
    UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
    final UserData? fetchUserData = await _userInfoDatabaseService.getUserData(userRef: widget.profileRef);
    if (mounted) {
      setState(() {
        profileUsername = fetchUserData != null ? fetchUserData.displayedName : 'username';
        profileImageExists = fetchUserData != null && fetchUserData.profileImage != null;
        profileScore = fetchUserData != null ? fetchUserData.score : -1;
        profileImage = fetchUserData!.profileImage;
        profileImageURL = fetchUserData.profileImageURL;
        userGroupColor = fetchUserData != null ? fetchUserData.domainColor : null;
        userGroup = fetchUserData != null ? fetchUserData.domain : 'group';
      });
    }
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    if (fetchUserData != null) {
      var fetchUserDomain = await _groups.getGroup(FirebaseFirestore.instance.collection(C.groups).doc(fetchUserData.domain));
      if (mounted) {
        setState(() {
          userGroupString = fetchUserDomain != null ? fetchUserDomain.image : null;
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

    if (userData == null) {
      return Authenticate();
    }
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        SizedBox(height:(MediaQuery.of(context).size.height)/8),
        ProfileImage(
          profileImage: profileImage,
          profileImageURL: profileImageURL,
          profileImageExists: profileImageExists,
          currUserName: profileUsername,
          showEditIcon: widget.profileRef == widget.currUserRef && widget.currUserRef == userData.userRef,
        ),
        SizedBox(height: 10),
        ProfileName(name: profileUsername, domain: userData.domain),
        SizedBox(height: 15),
        Row(

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Spacer(),
            GroupTag(groupImage: userGroupString!= null ? Image.network(userGroupString!) :
                 null, groupName: userGroup,
                fontSize: 18, groupColor: userGroupColor != null ? userGroupColor!:
                    null,
            ),
            SizedBox(width:20),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: profileScore.toString(),
                      style: ThemeText.groupBold(color: ThemeColor.black, fontSize: 18 )),
                  TextSpan(text: " Likes ",
                      style: ThemeText.regularSmall(color: ThemeColor.mediumGrey, fontSize: 18)),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
        SizedBox(height:MediaQuery.of(context).size.height/10),
        widget.profileRef == widget.currUserRef
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[SizedBox(width: 45),
              NewMessageButton(otherUserRef: widget.profileRef,
                currUserRef: widget.currUserRef,)])
            : Container()
      ],
    );
  }
}
