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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ActionChip(
      labelPadding: EdgeInsets.all(0),
      padding: EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      pressElevation: pressElevation,
      label: Container(
        decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius)
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Theme.of(context).colorScheme.surface,
          ),
          margin: EdgeInsets.all(thickness),
          child: child,
        )
      ),
      onPressed: onPressed,
    );

    /*return DecoratedBox(
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        padding: padding != null ? padding : EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Theme.of(context).colorScheme.surface,
        ),
        margin: EdgeInsets.all(thickness),
        child: ActionChip(
          pressElevation: 0,
          padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
          backgroundColor: Theme.of(context).colorScheme.surface,
          onPressed: onPressed,
          label: child,
        ),
      ),
    );*/
  }
}