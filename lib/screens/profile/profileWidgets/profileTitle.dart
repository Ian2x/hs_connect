import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';


class ProfileTitle extends StatelessWidget {

  final Color? otherUserDomainColor;
  final String otherUserFundName;
  final String? otherUserFullDomain;
  final int otherUserScore;

  const ProfileTitle({Key? key,
    required this.otherUserDomainColor,
    required this.otherUserFundName,
    required this.otherUserFullDomain,
    required this.otherUserScore,})
  : super(key: key);

  @override
  Widget build(BuildContext context) {

    final wp= Provider.of<HeightPixel>(context).value;

    return Row(
      children: [
        Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal:20*wp),
              child: ProfileImage(
                background:otherUserDomainColor,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  otherUserFundName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight:FontWeight.w600, fontSize: 19),
                ),
              ],
            ),
            SizedBox(height:5),
            Row(
              children: [
                Text(
                    otherUserFullDomain! + " ∙ " + otherUserScore.toString() + " Likes",
                    style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 17)),
              ],
            ),
          ],
        )
      ],
    );
  }
}

