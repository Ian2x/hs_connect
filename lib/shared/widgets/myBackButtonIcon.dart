import 'package:flutter/material.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

IconButton myBackButtonIcon(BuildContext context, {Color? overrideColor, VoidFunction? onPressed}) {
  final colorScheme = Theme.of(context).colorScheme;
  return IconButton(
    constraints: BoxConstraints(),
    icon: Icon(Icons.arrow_back_ios, color: overrideColor ?? colorScheme.onSurface, size: 22),
    onPressed: () {
      if (onPressed != null) {
        onPressed();
      } else {
        Navigator.of(context).pop();
      }
    },
  );
}
