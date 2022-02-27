import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

import 'package:hs_connect/shared/widgets/myOutlinedButton.dart';

class AuthButton extends StatelessWidget {
  final String buttonText;
  final VoidFunction onPressed;
  final bool hasText;
  final double? width;

  const AuthButton({Key? key, required this.buttonText,
    required this.onPressed,
    required this.hasText,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MyOutlinedButton(
      padding: EdgeInsets.symmetric(vertical: 9, horizontal: 30),
      onPressed: onPressed,
      outlineColor: hasText ? Colors.white : Colors.black54,
      borderRadius: 40,
      backgroundColor: hasText ? Colors.black : Colors.white,
      thickness: 2,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          buttonText,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: ThemeText.quicksand(
              fontWeight: FontWeight.w600, fontSize: 18,
              color: hasText ? Colors.white : Colors.black54),
        ),
      ),
    );
  }
}
