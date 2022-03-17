import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? spinColor;

  const Loading({Key? key, this.size = 50.0, this.backgroundColor, this.spinColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: backgroundColor ?? colorScheme.surface,
      child: Center(
        child: SpinKitPulse(
          color: spinColor ?? colorScheme.primary,
          size: size,
        ),
      ),
    );
  }
}
