import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

class AuthButton extends StatelessWidget {
  final String buttonText;
  final VoidFunction onPressed;
  final bool hasText;

  const AuthButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    required this.hasText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          decoration: BoxDecoration(
            color: hasText ? Colors.black : Colors.black54,
            borderRadius: BorderRadius.circular(40),
          ),
          margin: EdgeInsets.only(bottom: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 29),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              color: hasText ? Colors.black : Colors.white,
            ),
            margin: EdgeInsets.all(2),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                buttonText,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: ThemeText.quicksand(
                    fontWeight: FontWeight.w600, fontSize: 18, color: hasText ? Colors.white : Colors.black54),
              ),
            ),
          )),
    );
  }
}
