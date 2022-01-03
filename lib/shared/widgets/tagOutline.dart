import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

class tagOutline extends StatelessWidget {
  Widget? widget;
  final bool textOnly;
  String? text;

  tagOutline({Key? key, required bool this.textOnly, this.widget, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: EdgeInsets.fromLTRB(8.0, 0.0, 3.0, 0.0),
      decoration: ShapeDecoration(
        color: HexColor('FFFFFF'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0),
            side: BorderSide(
              color: HexColor("E9EDF0"),
              width: 3.0,
            )),
      ),
      child: textOnly != true
          ? widget
          : Text(text!,
              style: TextStyle(
                color: HexColor("b5babe"),
                fontFamily: "",
              )),
    );
  }
}
