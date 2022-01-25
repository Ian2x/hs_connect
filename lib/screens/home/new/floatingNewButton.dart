import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:provider/provider.dart';
import 'newPost/newPost.dart';

FloatingActionButton floatingNewButton(BuildContext context) {
  final hp = Provider.of<HeightPixel>(context).value;
  return FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => pixelProvider(context, child: NewPost())),
      );
    },
    backgroundColor: ThemeColor.secondaryBlue,
    foregroundColor: HexColor('FFFFFF'),
    elevation: 6*hp,
  );
}