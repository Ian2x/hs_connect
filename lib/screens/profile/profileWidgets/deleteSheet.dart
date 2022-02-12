import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/reports/reportForm.dart';
import 'package:hs_connect/shared/widgets/blockConfirmationDialog.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class deleteSheet extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference postUserRef;
  final DocumentReference groupRef;
  final DocumentReference postRef;
  final String? media;

  const deleteSheet(
      {Key? key,
        required this.currUserRef,
        required this.postUserRef,
        required this.groupRef,
        required this.postRef,
        this.media})
      : super(key: key);

  @override
  _deleteSheetState createState() => _deleteSheetState();
}

class _deleteSheetState extends State<deleteSheet> with TickerProviderStateMixin {
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

    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.currUserRef);


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

    return Container(
      constraints: BoxConstraints(
        maxHeight:
              165 * hp + MediaQuery
            .of(context)
            .padding
            .bottom,
      ),
      padding: EdgeInsets.fromLTRB(13 * wp, 0, 0, MediaQuery
          .of(context)
          .padding
          .bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              TextButton(
                onPressed: () {
                  _posts.deletePost(
                      postRef: widget.postRef, userRef: widget.currUserRef, groupRef: widget.groupRef, media: widget.media);
                },
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, color: colorScheme.primary, size: iconSize * hp),
                    SizedBox(width: 20 * wp),
                    Text(
                      "Delete forever",
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
          )
      );
  }
}
