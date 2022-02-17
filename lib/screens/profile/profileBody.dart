import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileTitle.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profilePostFeed.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class ProfileBody extends StatelessWidget {
  final UserData currUserData;

  ProfileBody({Key? key, required this.currUserData}) : super(key: key);
@override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          SizedBox(height: 20 * hp),
          Row(
            children: [
              ProfileTitle(
                otherUserFundName: currUserData.fundamentalName,
                otherUserScore: currUserData.score,
                otherUserDomainColor: currUserData.domainColor,
                otherUserFullDomain: currUserData.fullDomainName,
              ),
            ],
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
              SizedBox(height: 30 * hp),
              ProfilePostFeed(profileUserData: currUserData),
                ])
        ],
      ),
    );
  }
}
