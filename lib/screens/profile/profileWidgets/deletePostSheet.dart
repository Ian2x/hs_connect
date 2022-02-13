import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/confirmationDialogs.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class DeletePostSheet extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference postUserRef;
  final DocumentReference groupRef;
  final DocumentReference postRef;
  final String? media;
  final VoidFunction onDelete;

  const DeletePostSheet(
      {Key? key,
      required this.currUserRef,
      required this.postUserRef,
      required this.groupRef,
      required this.postRef,
      this.media,
      required this.onDelete})
      : super(key: key);

  @override
  _DeletePostSheetState createState() => _DeletePostSheetState();
}

class _DeletePostSheetState extends State<DeletePostSheet> with TickerProviderStateMixin {
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

    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    final userData = Provider.of<UserData?>(context);
    if (userData == null) return Loading();

    final bottomSpace = max(MediaQuery.of(context).padding.bottom, 25*hp);

    return Container(
        constraints: BoxConstraints(
          maxHeight: 104 * hp + bottomSpace,
        ),
        padding: EdgeInsets.fromLTRB(13 * wp, 5*hp, 0, bottomSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () async {
                deletePostConfirmationDialog(context,
                    content:
                    "Would you like to delete this post? This action cannot be undone.",
                    action: () async {
                      await _posts.deletePost(
                          postRef: widget.postRef,
                          userRef: widget.currUserRef,
                          groupRef: widget.groupRef,
                          media: widget.media);
                      widget.onDelete();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    });
              },
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, color: colorScheme.primary, size: iconSize * hp),
                  SizedBox(width: 20 * wp),
                  Text(
                    "Delete forever",
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.primaryVariant),
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
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.primaryVariant),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }
}
