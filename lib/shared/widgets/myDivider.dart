import 'package:flutter/material.dart';

class MyDivider extends Divider implements PreferredSizeWidget {
  MyDivider({
    Key? key,
    height = 1.0,
    indent = 0.0,
    thickness = 1.0,
    color,
  }) : assert(height >= 0.0),
        super(
        key: key,
        height: height,
        indent: indent,
        thickness: thickness,
        color: color,
      ) {
    preferredSize = Size(double.infinity, height);
  }

  @override
  late Size preferredSize;
}