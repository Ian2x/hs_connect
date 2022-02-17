import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/profileSheetTitle.dart';
import 'package:hs_connect/screens/profile/profileWidgets/newMessageButton.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/confirmationDialogs.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

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
  static const double iconSize = 20;
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

    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    final userData = Provider.of<UserData?>(context);
    if (userData == null) return Loading();

    final bottomSpace = max(MediaQuery.of(context).padding.bottom, 25*hp);

    return Container(
        constraints: BoxConstraints(
          maxHeight:isOwn?
          140 * hp + bottomSpace:
          204 * hp + bottomSpace,
        ),
        padding: EdgeInsets.fromLTRB(13 * wp, 5*hp, 0, bottomSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.close_rounded, size: iconSize * hp, color: colorScheme.primary),
                  ],
                )),
            ProfileTitle(
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
