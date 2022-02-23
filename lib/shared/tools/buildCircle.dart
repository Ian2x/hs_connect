import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hs_connect/services/storage/image_storage.dart';

Widget buildGroupCircle(
    {required String? groupImage,
    required double height,
    required double width,
    required BuildContext context,
    required Color backgroundColor,
    required }) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(100),
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 0.15),
    ),
    alignment: Alignment.center,
    child: Container(
        height: groupImage==null ? 0.6 * min(height, width) : null,
        width: groupImage==null ? 0.6 * min(height, width) : null,
        decoration: BoxDecoration(image: DecorationImage(image: ImageStorage().groupImageProvider(groupImage)))),
  );
}
