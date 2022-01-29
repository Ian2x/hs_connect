import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';
import 'newPost/newPost.dart';

Widget floatingNewButton(BuildContext context) {
  final hp = Provider.of<HeightPixel>(context).value;
  final colorScheme = Theme.of(context).colorScheme;

  //return Icon(Icons.add, color: Colors.green, size: 50);

  /*return Container(
    child: ShaderMask(
      shaderCallback: (Rect bounds) {
        return RadialGradient(
          center: Alignment.bottomLeft,
          radius: 0.5,
          colors: <Color>[
            Colors.blue,
            Colors.amberAccent
          ],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: Icon(Icons.add, size: 50, color: Colors.green),
    ),
  );*/

  return Container(
    height: 55,
    width: 55,
    margin: EdgeInsets.only(right: 3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: Gradients.blueRed()
    ),
    padding: EdgeInsets.all(4),
    child: Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return Gradients.blueRed().createShader(bounds);
        },
        child: Icon(Icons.add, size: 45, color: Colors.white),
      ),
    ),
  );
}
/*
FloatingActionButton(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return Gradients.blueRed().createShader(bounds);
        },
        child: Icon(Icons.add, size: 42, color: Colors.white),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pixelProvider(context, child: NewPost())),
        );
      },
      backgroundColor: colorScheme.surface,
      //foregroundColor: Colors.transparent,
      elevation: 6*hp,
    ),
 */