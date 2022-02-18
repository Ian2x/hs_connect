import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/myOutlinedButton.dart';
import 'package:provider/provider.dart';


class AuthButton extends StatelessWidget {
  final String buttonText;
  final VoidFunction onPressed;
  final bool hasText;

  const AuthButton({Key? key, required this.buttonText, required this.onPressed, required this.hasText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;

    return MyOutlinedButton(
      padding: EdgeInsets.symmetric(vertical: 9*hp, horizontal: 35),
      onPressed: onPressed,
      outlineColor: hasText ? Colors.black : Colors.black54,
      borderRadius: 40*hp,
      backgroundColor: Colors.white,
      thickness: 1.2*hp,
      child: FittedBox(
        child: Text(
          buttonText,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: ThemeText.helvetica(fontWeight: FontWeight.w500, color: hasText ? Colors.black : Colors.black54),
        ),
      ),
    );
  }
}
