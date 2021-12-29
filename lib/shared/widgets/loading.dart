import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor("FFFFFF"),
      child: Center(
        child: SpinKitChasingDots(
          color: HexColor("222426"),
          size: 50.0,
        ),
      ),
    );
  }
}
