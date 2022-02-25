import 'package:flutter/material.dart';

import '../tools/helperFunctions.dart';

IconButton myBackButtonIcon(BuildContext context, {Color? overrideColor, dynamic onPressed }) {

  final colorScheme = Theme.of(context).colorScheme;
  return IconButton(
    constraints: BoxConstraints(),
    icon: Icon(Icons.arrow_back_ios, color: overrideColor!= null ? overrideColor : colorScheme.onSurface, size: 22),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
}
