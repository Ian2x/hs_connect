import 'package:flutter/material.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';
import 'newPost/newPost.dart';

FloatingActionButton floatingNewButton(BuildContext context) {
  final hp = Provider.of<HeightPixel>(context).value;
  final colorScheme = Theme.of(context).colorScheme;

  return FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => pixelProvider(context, child: NewPost())),
      );
    },
    backgroundColor: colorScheme.secondary,
    foregroundColor: colorScheme.surface,
    elevation: 6*hp,
  );
}