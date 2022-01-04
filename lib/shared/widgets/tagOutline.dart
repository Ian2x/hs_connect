import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';


class tagOutline extends StatelessWidget {
  Widget? widget;
  final bool textOnly;
  String? text;
  String? textColor;
  String? fillColor;
  String? borderColor;


  tagOutline({Key? key,
    required bool this.textOnly,
    this.textColor,
    this.borderColor,
    this.fillColor,
    this.widget, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 35,
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      decoration: ShapeDecoration(
        color: fillColor != null ? HexColor(fillColor!): HexColor('FFFFFF'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: borderColor != null? HexColor(borderColor!):HexColor("E9EDF0"),
              width: 3.0,
            )),
      ),
      child:
      textOnly != true ? widget
          : Text(text!,
          style: TextStyle(
            color: textColor !=null ? HexColor (textColor!):HexColor("b5babe"),
            fontSize:16,
            fontFamily: "",
          )),
    );
  }
}