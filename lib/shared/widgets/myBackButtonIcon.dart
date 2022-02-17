import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pixels.dart';

IconButton myBackButtonIcon(BuildContext context, {Color? overrideColor}) {
  final hp = Provider.of<HeightPixel>(context).value;
  final colorScheme = Theme.of(context).colorScheme;
  return IconButton(
    constraints: BoxConstraints(),
    icon: Icon(Icons.arrow_back_ios, color: overrideColor!= null ? overrideColor : colorScheme.onSurface, size: 26*hp),
    onPressed: () => Navigator.of(context).pop(),
  );
}
