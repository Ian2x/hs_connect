import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myCircle.dart';

import '../constants.dart';
import 'helperFunctions.dart';

Widget circleFromGroup({required Group? group, required double circleSize}) {
  if (group == null) {
    return Circle(
        size: circleSize, child: Loading(size: circleSize * 0.6), textBackgroundColor: ThemeColor.backgroundGrey);
  } else if (group.image != null) {
    return Circle(
      size: circleSize,
      child: Image.network(group.image!),
      textBackgroundColor: ThemeColor.backgroundGrey,
    );
  } else {
    String s = group.name;
    int sLen = s.length;
    String initial = "?";
    for (int j = 0; j < sLen; j++) {
      if (RegExp(r'[a-z]').hasMatch(group.name[j].toLowerCase())) {
        initial = group.name[j].toUpperCase();
        break;
      }
    }
    return Circle(
        size: circleSize,
        textBackgroundColor: translucentColorFromString(group.name),
        child: Text(initial, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)));
  }
}
