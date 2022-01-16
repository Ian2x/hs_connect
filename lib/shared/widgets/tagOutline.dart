import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';


class TagOutline extends StatelessWidget {
  final Widget? widget;
  final bool textOnly;
  final String? text;
  final Color? textColor;
  final Color? fillColor;
  final Color? borderColor;
  final double? height;
  final EdgeInsetsGeometry? padding;


  TagOutline({Key? key,
    required bool this.textOnly,
    this.textColor,
    this.borderColor,
    this.fillColor,
    this.height=35,
    this.padding,
    this.widget, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: height,
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      decoration: ShapeDecoration(
        color: fillColor != null ? fillColor!: HexColor('FFFFFF'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: borderColor != null? borderColor! :HexColor("E9EDF0"),
              width: 3.0,
            )),
      ),
      child:
      textOnly != true ? widget
          : Text(text!,
          style: TextStyle(
            color: textColor !=null ? textColor! : HexColor("b5babe"),
            fontSize:16,
            fontFamily: "",
          )),
    );
  }
}