import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final Color? backgroundColor;
  final double size;

  ProfileImage({
    Key? key,
    required this.backgroundColor,
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Image logoImage = backgroundColor != null ? Image.asset("assets/White400.png") : Image.asset("assets/Splash2.png");

    return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? colorScheme.surface,
          border: Border.all(color: colorScheme.background, width: 1.5),
        ),
        child: Container(height: size * 0.6, width: size * 0.6, alignment: Alignment.center, child: logoImage));
  }
}
