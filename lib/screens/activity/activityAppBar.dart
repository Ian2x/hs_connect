import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';

AppBar activityAppBar({required double wp, required double hp}) {
  return AppBar(
      backgroundColor: ThemeColor.white,
      elevation: 0,
      toolbarHeight: 80*hp,
      title: Row(children: <Widget>[
        SizedBox(width: 13*wp),
        Text('Activity',
            style:
                TextStyle(fontFamily: "Inter", fontSize: 28*hp, color: ThemeColor.black, fontWeight: FontWeight.w600))
      ],
      ),
  );
}
