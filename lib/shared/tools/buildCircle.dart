import 'package:flutter/material.dart';

import '../constants.dart';

Widget buildProfileCircle({
  required Widget child,
  required double all,
  required Color color,
}) {
  return ClipOval(
    child: Container(
      padding: EdgeInsets.all(all),
      color: color,
      child: child,
    ),
  );
}

Widget buildGroupCircle({
  required Widget child,
  required double all,
  required Color backgroundColor
}) {
  return ClipOval(
    child: Container(
      padding: EdgeInsets.all(all),
      decoration: BoxDecoration(
        gradient: Gradients.blueRed(),
      ),
      child: buildProfileCircle(
        all: all,
        color: backgroundColor,
        child: child
      )
    )
  );
}