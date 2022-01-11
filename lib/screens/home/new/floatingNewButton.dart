import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'newPost/newPost.dart';

FloatingActionButton floatingNewButton(BuildContext context) {
  return FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NewPost()),
      );
    },
    backgroundColor: ThemeColor.secondaryBlue,
    foregroundColor: HexColor('FFFFFF'),
    elevation: 6.0,
  );
}