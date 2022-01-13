import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';

class newResponseIcon extends StatelessWidget {

  const newResponseIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
