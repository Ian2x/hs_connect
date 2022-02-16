import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';


class ProfileTitle extends StatelessWidget {

  final UserData otherUserData;

  const ProfileTitle({Key? key, required this.otherUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            ProfileImage(
              background:otherUserData.domainColor,
              currUserName: otherUserData.fundamentalName,
              showEditIcon: false,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  otherUserData.fundamentalName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight:FontWeight.w600, fontSize: 19),
                ),
              ],
            ),
            SizedBox(height:2),
            Row(
              children: [
                Text(
                    otherUserData.fullDomainName! + " ∙ " + otherUserData.score.toString() + " Likes",
                    style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 17)),
              ],
            ),
          ],
        )
      ],
    );
  }
}

