import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

class Loading extends StatelessWidget {
  final double size;
  const Loading({Key? key, this.size=50.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: SpinKitFadingCircle(
          color: HexColor("222426"),
          size: size,
        ),
      ),
    );
  }
}