import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
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
        color:Colors.transparent,
        padding: EdgeInsets.fromLTRB(10*wp, 3*hp, 10*wp, 5*hp),
        width: MediaQuery.of(context).size.width,
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MyOutlinedButton(
              padding: EdgeInsets.symmetric(vertical: 11*hp, horizontal: 35*wp),
              onPressed: onPressed,
              outlineColor: Colors.black,
              borderRadius: 40*hp,
              backgroundColor: Colors.white,
              thickness: 1.2*hp,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  buttonText,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeText.inter(fontWeight: FontWeight.w500, color: Colors.black,
                  ),
                ),
              ),
            )
          ]
        ),
    );
  }
}
