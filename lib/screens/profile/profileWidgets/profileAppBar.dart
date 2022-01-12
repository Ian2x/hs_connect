import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';

AppBar profileAppBar(BuildContext context) {
  final icon = CupertinoIcons.moon_stars;

  return AppBar(
    iconTheme: IconThemeData(
      color: ThemeColor.black, //change your color here
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        icon: Icon(icon),
        onPressed: () {},
      ),
    ],
  );
}
