import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final Color? background;
  final double size;

  ProfileImage({
    Key? key,
    required this.background,
    this.size=60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Image logoImage;

    if (background != null) {
      logoImage = Image.asset("assets/White400.png");
    } else {
      logoImage = Image.asset("assets/Splash2.png");
    }

    return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background != null ? background : colorScheme.surface,
          border: Border.all(color: colorScheme.background, width: 1.5),
        ),
      child: Container(
        height: size * 0.6,
        width: size * 0.6,
        alignment: Alignment.center,
        child: logoImage
      )
    );
  }
}
