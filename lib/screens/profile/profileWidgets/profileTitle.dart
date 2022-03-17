import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';

class ProfileTitle extends StatelessWidget {
  final bool showMoreHoriz;
  final DocumentReference otherUserRef;
  final Color? otherUserDomainColor;
  final String otherUserFundName;
  final String otherUserFullDomain;
  final int otherUserScore;

  const ProfileTitle({
    Key? key,
    required this.showMoreHoriz,
    required this.otherUserRef,
    required this.otherUserDomainColor,
    required this.otherUserFundName,
    required this.otherUserFullDomain,
    required this.otherUserScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ProfileImage(
                backgroundColor: otherUserDomainColor,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUserFundName,
                  textAlign: TextAlign.center,
                  style: textTheme.headline5?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Text(otherUserFullDomain,
                        style: textTheme.headline6),
                    SizedBox(width: 15),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 2, 10, 4),
                      decoration: BoxDecoration(
                        color: otherUserDomainColor ?? colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(otherUserScore.toString() + " Likes", style: textTheme.headline6?.copyWith(color: colorScheme.brightness==Brightness.light ? colorScheme.surface : null))
                    )
                  ]
                ),
              ],
            ),
          ],
        ),
        Spacer(),
        showMoreHoriz
            ? Column(
                children: [
                  IconButton(
                      icon: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.primary),
                      constraints: BoxConstraints(),
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            )),
                            builder: (context) => ReportSheet(
                                  reportType: ReportType.user,
                                  entityRef: otherUserRef,
                                  entityCreatorRef: otherUserRef,
                                ));
                      }),
                ],
              )
            : Container()
      ],
    );
  }
}
