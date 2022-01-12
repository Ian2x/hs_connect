import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';

AppBar notificationsAppBar() {
  return AppBar(
      backgroundColor: ThemeColor.white,
      elevation: 0.0,
      toolbarHeight: 80.0,
      title: Row(children: <Widget>[
        SizedBox(width: 13.0),
        Text('Activity',
            style:
                TextStyle(fontFamily: "Inter", fontSize: 28.0, color: ThemeColor.black, fontWeight: FontWeight.w600))
      ])
  );
}
