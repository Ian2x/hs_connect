import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pixels.dart';

IconButton myBackButtonIcon(BuildContext context) {
  final hp = Provider.of<HeightPixel>(context).value;
  return IconButton(
    icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 26*hp),
    onPressed: () => Navigator.of(context).pop(),
  );
}
