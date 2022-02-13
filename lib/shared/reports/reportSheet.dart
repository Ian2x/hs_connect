import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/reports/reportForm.dart';
import 'package:hs_connect/shared/widgets/confirmationDialogs.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../pixels.dart';
import '../widgets/loading.dart';

class ReportSheet extends StatefulWidget {
  final ReportType reportType;
  final DocumentReference entityRef; // ref to message, post, comment, or reply
  final DocumentReference entityCreatorRef;

  const ReportSheet({Key? key, required this.reportType, required this.entityRef, required this.entityCreatorRef})
      : super(key: key);

  @override
  _ReportSheetState createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> with TickerProviderStateMixin {
  static const double iconSize = 20;
  late AnimationController controller;
  bool disposeController = true;

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
    final hp = Provider
        .of<HeightPixel>(context)
        .value;
    final wp = Provider
        .of<WidthPixel>(context)
        .value;
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    final userData = Provider.of<UserData?>(context);
    if (userData == null) return Loading();

    final bottomSpace = max(MediaQuery.of(context).padding.bottom, 25*hp);

    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.reportType == ReportType.post
            ? 200 * hp + bottomSpace
            : 152 * hp + bottomSpace,
      ),
      padding: EdgeInsets.fromLTRB(13 * wp, 5*hp, 0, bottomSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      pixelProvider(context,
                          child: ReportForm(entityRef: widget.entityRef, reportType: widget.reportType))));
            },
            child: Row(
              children: [
                Icon(Icons.flag, color: colorScheme.primary, size: iconSize * hp),
                SizedBox(width: 20 * wp),
                Text(
                  "Report " + widget.reportType.string,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(color: colorScheme.primaryVariant),
                ),
              ],
            ),
          ),
          Divider(color: colorScheme.background, thickness: 1 * hp, height: 0),
          widget.reportType == ReportType.post
              ? Column(children: [
            TextButton(
              onPressed: () {
                blockConfirmationDialog(context,
                    content: "Would you like to hide this post? This action cannot be undone.",
                    action: () async {
                      await userData.userRef.update({
                        C.blockedPostRefs: FieldValue.arrayUnion([widget.entityRef])
                      });
                      Navigator.of(context).pop();
                    });
              },
              child: Row(
                children: [
                  Icon(Icons.remove_circle_rounded, color: colorScheme.primary, size: iconSize * hp),
                  SizedBox(width: 20 * wp),
                  Text(
                    "Hide post",
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(color: colorScheme.primaryVariant),
                  ),
                ],
              ),
            ),
            Divider(color: colorScheme.background, thickness: 1 * hp, height: 0),
          ])
              : Container(),
          TextButton(
            onPressed: () async {
              blockConfirmationDialog(context,
                  content:
                  "Would you like to block this user and all their content? This action cannot be undone.",
                  action: () async {
                    await userData.userRef.update({
                      C.blockedUserRefs: FieldValue.arrayUnion([widget.entityCreatorRef])
                    });
                    Navigator.of(context).pop();
                  });
            },
            child: Row(
              children: [
                Icon(Icons.no_accounts_rounded, color: colorScheme.primary, size: iconSize * hp),
                SizedBox(width: 20 * wp),
                Text(
                  "Block user",
                  style: Theme
                      .of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(color: colorScheme.primaryVariant),
                ),
              ],
            ),
          ),
          Divider(color: colorScheme.background, thickness: 1 * hp, height: 0),
          Container(
            //color: Colors.orange,
            child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.close_rounded, size: iconSize * hp, color: colorScheme.primary),
                    SizedBox(width: 20 * wp),
                    Text(
                      "Cancel",
                      style: Theme
                          .of(context)
                          .textTheme
                          .subtitle1
                          ?.copyWith(color: colorScheme.primaryVariant),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
