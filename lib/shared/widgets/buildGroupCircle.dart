import 'package:flutter/material.dart';
import 'package:hs_connect/services/storage/image_storage.dart';

Widget buildGroupCircle(
    {required String? groupImage,
    required double size,
    required BuildContext context,
    required Color backgroundColor,
    bool noBorder = false}) {
  return Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(100),
      color: backgroundColor,
      border: noBorder ? null : Border.all(color: Theme.of(context).colorScheme.primary, width: 0.15),
    ),
    alignment: Alignment.center,
    child: Container(
        height: groupImage == null ? 0.6 * size : null,
        width: groupImage == null ? 0.6 * size : null,
        decoration: BoxDecoration(
            borderRadius: groupImage != null ? BorderRadius.circular(100) : null,
            image: DecorationImage(image: ImageStorage().groupImageProvider(groupImage)))),
  );
}
