import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';

class NumResponseIcon extends StatelessWidget {
  final int numResponse;

  const NumResponseIcon({Key? key, required this.numResponse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (numResponse >= 0) {
      return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          color: ThemeColor.lightGrey,
          child: Container(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.chat_bubble_rounded, color: ThemeColor.white, size: 12.0),
                SizedBox(width: 5.0),
                Text(numResponse.toString(), style: ThemeText.regularSmall(color: ThemeColor.white))
              ],
            ),
          ));
    } else {
      return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          color: ThemeColor.secondaryBlue,
          child: Container(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.chat_bubble_rounded, color: ThemeColor.white, size: 12.0),
                SizedBox(width: 5.0),
                Text("New", style: ThemeText.regularSmall(color: ThemeColor.white))
              ],
            ),
          ));
    }
  }
}
