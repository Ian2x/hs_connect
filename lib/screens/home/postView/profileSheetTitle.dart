import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';


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
    return Row(
      children: [
        Column(
          children: [
            ProfileImage(
              background:otherUserDomainColor,
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
            SizedBox(height:2),
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

