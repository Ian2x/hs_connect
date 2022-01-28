import 'package:flutter/material.dart';

class MyOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Gradient? gradient;
  final double thickness;
  final double borderRadius;

  const MyOutlinedButton({
    Key? key,
    required this.borderRadius,
    required this.onPressed,
    required this.child,
    this.style,
    this.gradient,
    this.thickness = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
        ),
        margin: EdgeInsets.all(thickness),
        child: ActionChip(
          padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
          backgroundColor: Colors.white,
          onPressed: onPressed,
          label: child,
        ),
      ),
    );
  }
}