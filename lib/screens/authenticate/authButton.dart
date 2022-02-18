import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

import 'package:hs_connect/shared/widgets/myOutlinedButton.dart';

class AuthButton extends StatelessWidget {
  final String buttonText;
  final VoidFunction onPressed;
  final bool hasText;

  const AuthButton({Key? key, required this.buttonText, required this.onPressed, required this.hasText}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MyOutlinedButton(
      padding: EdgeInsets.symmetric(vertical: 9, horizontal: 35),
      onPressed: onPressed,
      outlineColor: hasText ? Colors.black : Colors.black54,
      borderRadius: 40,
      backgroundColor: Colors.white,
      thickness: 1.2,
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
