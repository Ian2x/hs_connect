import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  const Loading({Key? key, this.size=50.0, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: backgroundColor!= null ? backgroundColor : colorScheme.background,
      child: Center(
        child: SpinKitFadingCircle(
          color: colorScheme.primaryVariant,
          size: size,
        ),
      ),
    );
  }
}