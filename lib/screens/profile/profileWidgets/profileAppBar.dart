import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar profileAppBar(BuildContext context) {
  final icon = CupertinoIcons.moon_stars;

  return AppBar(
    iconTheme: IconThemeData(
      color: Theme.of(context).colorScheme.onSurface, //change your color here
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
