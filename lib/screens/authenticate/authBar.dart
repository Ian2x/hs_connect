import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';


class AuthBar extends StatefulWidget {

  final String buttonText;
  final VoidFunction onPressed;

  const AuthBar({Key? key, required this.buttonText,
    required this.onPressed
  }) : super(key: key);

  @override
  _AuthBarState createState() => _AuthBarState();
}

class _AuthBarState extends State<AuthBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0.0,3.0, 10.0, 0.0),
        height: MediaQuery.of(context).size.height/15,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: ThemeColor.white,
          border: Border(
            top: BorderSide(width: 1.0, color: ThemeColor.lightMediumGrey),
          ),
        ),
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Spacer(),
             Container(
                height: 10,
                padding: EdgeInsets.all(0),
                decoration: ShapeDecoration(
                  color: ThemeColor.secondaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ))),
              child:
                TextButton(
                  onPressed: widget.onPressed,
                  child:
                  Text(widget.buttonText,
                      style: ThemeText.regularSmall(fontSize:18, color: ThemeColor.white)),
                ),
             ),
          ]
        ),
    );
  }
}
