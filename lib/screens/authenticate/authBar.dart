import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';


class AuthBar extends StatelessWidget {
  final double hp;
  final double wp;
  final String buttonText;

  const AuthBar({Key? key, required this.buttonText,required this.hp, required this.wp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0*wp, 3*hp, 10*wp, 0*hp),
        height: MediaQuery.of(context).size.height/15,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: ThemeColor.white,
          border: Border(
            top: BorderSide(width: 1*wp, color: ThemeColor.lightMediumGrey),
          ),
        ),
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Spacer(),
             Container(
                height: 10*wp,
                padding: EdgeInsets.all(0),
                decoration: ShapeDecoration(
                  color: ThemeColor.secondaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20*hp),
                      ))),
              child:
                TextButton(
                  onPressed: (){},
                  child:
                  Text(buttonText,
                      style: ThemeText.regularSmall(fontSize:18*hp, color: ThemeColor.white)),
                ),
             ),
          ]
        ),
    );
  }
}
