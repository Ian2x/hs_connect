import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';
import 'package:hs_connect/shared/widgets/myOutlinedButton.dart';
import 'package:provider/provider.dart';


class AuthBar extends StatelessWidget {
  final String buttonText;
  final VoidFunction onPressed;

  const AuthBar({Key? key, required this.buttonText, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;

    return Container(
        color:Colors.white,
        padding: EdgeInsets.fromLTRB(10*wp, 3*hp, 10*wp, 5*hp),
        width: MediaQuery.of(context).size.width,
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MyOutlinedButton(
              padding: EdgeInsets.symmetric(vertical: 12*hp, horizontal: 40*wp),
              onPressed: onPressed,
              gradient: Gradients.blueRed(begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: 40,
              backgroundColor: Colors.white,
              child: GradientText(
                buttonText,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: ThemeText.inter(fontWeight: FontWeight.w500, fontSize: 17*hp,
                ),
                gradient: Gradients.blueRed(),
              ),
            )
          ]
        ),
    );
  }
}
