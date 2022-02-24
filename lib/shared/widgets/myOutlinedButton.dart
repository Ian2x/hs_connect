import 'package:flutter/material.dart';

class MyOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Gradient? gradient;
  final double thickness;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? pressElevation;
  final Color? backgroundColor;
  final Color? outlineColor;
  final double? width;
  final double? height;

  const MyOutlinedButton({
    Key? key,
    required this.borderRadius,
    required this.onPressed,
    required this.child,
    this.style,
    this.gradient,
    this.padding,
    this.pressElevation,
    this.thickness = 2,
    this.backgroundColor,
    this.outlineColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            color: outlineColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius-thickness),
              color: backgroundColor,
            ),
            margin: EdgeInsets.all(thickness),
            child: child,
          )
      ),
    );
  }
}