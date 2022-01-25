import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:provider/provider.dart';

import '../pixels.dart';


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
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    return Container(
      alignment: Alignment.center,
      height: height,
      padding: EdgeInsets.fromLTRB(10*wp, 5*hp, 10*wp, 5*hp),
      decoration: ShapeDecoration(
        color: fillColor != null ? fillColor!: HexColor('FFFFFF'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16*hp),
            side: BorderSide(
              color: borderColor != null? borderColor! :HexColor("E9EDF0"),
              width: 3*wp,
            )),
      ),
      child:
      textOnly != true ? widget
          : Text(text!,
          style: TextStyle(
            color: textColor !=null ? textColor! : HexColor("b5babe"),
            fontSize:16*hp,
            fontFamily: "",
          )),
    );
  }
}