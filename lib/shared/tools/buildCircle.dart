import 'package:flutter/material.dart';
import 'package:hs_connect/services/storage/image_storage.dart';

import '../constants.dart';

Widget buildGroupCircle({
  required String? groupImage,
  required double height,
  required double width,
  required BuildContext context,
  required Color backgroundColor
}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Theme.of(context).colorScheme.primary,
        border: Border.all(
            width: 0.15
        )
    ),
    child: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      backgroundImage: ImageStorage().groupImageProvider(groupImage),
    ),
  );
}