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
  final String? otherUserFullDomain;
  final int otherUserScore;

  const ProfileTitle({Key? key,
    required this.showMoreHoriz,
    required this.otherUserRef,
    required this.otherUserDomainColor,
    required this.otherUserFundName,
    required this.otherUserFullDomain,
    required this.otherUserScore,})
  : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal:20, vertical: 10),
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
                  style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight:FontWeight.w600, fontSize: 19),
                ),
                SizedBox(height: 5),
                Text(
                    otherUserFullDomain! + " ∙ " + otherUserScore.toString() + " Likes",
                    style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 17)),
              ],
            ),
          ],
        ),
        Spacer(),
        showMoreHoriz ? Column(
          children: [
            IconButton(
                icon: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.primaryVariant),
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
        ) : Container()
      ],
    );
  }
}

