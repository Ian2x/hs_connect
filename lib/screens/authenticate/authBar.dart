import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';
import 'package:hs_connect/shared/widgets/outlineButton.dart';
import 'package:provider/provider.dart';


class AuthBar extends StatelessWidget {
  final String buttonText;
  final VoidFunction onPressed;

  const AuthBar({Key? key, required this.buttonText, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      child: Container(
          color:Colors.white,
          padding: EdgeInsets.fromLTRB(10*wp, 3*hp, 10*wp, 5*hp),
          height: MediaQuery.of(context).size.height/15,
          width: MediaQuery.of(context).size.width,
          /*decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(width: 1*wp, color: colorScheme.onError),
            ),
          ),*/
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MyOutlinedButton(
                padding: EdgeInsets.fromLTRB(30.0, 0.0, 30, 0),
                onPressed: () {onPressed();},
                gradient: Gradients.blueRed(begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: 40.0,
                child: GradientText(
                  buttonText,
                  style: ThemeText.inter(fontWeight: FontWeight.w500, fontSize: 17*hp, //TODO: Convertto HP
                  ),
                  gradient: Gradients.blueRed(),
                ),
              )
            ]
          ),
      ),
    );
  }
}
