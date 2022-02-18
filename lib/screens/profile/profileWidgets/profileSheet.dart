import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileTitle.dart';
import 'package:hs_connect/screens/profile/profileWidgets/newMessageButton.dart';
import 'package:hs_connect/shared/reports/reportSheet.dart';
import 'package:hs_connect/shared/widgets/modalTab.dart';

class ProfileSheet extends StatefulWidget {
  final DocumentReference otherUserRef;
  final DocumentReference currUserRef;
  final String otherUserFundName;
  final String otherUserFullDomain;
  final int otherUserScore;
  final Color? otherUserDomainColor;

  const ProfileSheet(
      {Key? key,
        required this.otherUserScore,
        required this.otherUserRef,
        required this.currUserRef,
        required this.otherUserFullDomain,
        required this.otherUserDomainColor,
        required this.otherUserFundName,
        })
      : super(key: key);

  @override
  _ProfileSheetState createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> with TickerProviderStateMixin {
  late AnimationController controller;
  bool disposeController = true;

  bool isOwn=false;



  @override
  void initState() {
    controller = BottomSheet.createAnimationController(this);
    controller.duration = Duration(milliseconds: 250);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    if (widget.currUserRef == widget.otherUserRef){
      isOwn=true;
    }



    final colorScheme = Theme.of(context).colorScheme;

    final double bottomSpace = max(MediaQuery.of(context).padding.bottom, 25);

    return Container(
        constraints: BoxConstraints(
          maxHeight:isOwn?
          140 + bottomSpace:
          204 + bottomSpace,
        ),
        padding: EdgeInsets.fromLTRB(5, 5, 5, bottomSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                modalTab(),
              ],
            ),
            ProfileTitle(
                otherUserRef: widget.otherUserRef,
                otherUserDomainColor: widget.otherUserDomainColor!,
                otherUserFullDomain: widget.otherUserFullDomain,
                otherUserFundName: widget.otherUserFundName,
                otherUserScore: widget.otherUserScore,
            ),
            isOwn?
                Container():
            NewMessageButton(otherUserRef: widget.otherUserRef,
              currUserRef: widget.currUserRef,
              otherUserFundName: widget.otherUserFundName,
            ),
          ],
        ));
  }
}
