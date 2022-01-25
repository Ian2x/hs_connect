import 'package:flutter/material.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

AppBar activityAppBar({required BuildContext context}) {
  final wp = Provider.of<WidthPixel>(context).value;
  final hp = Provider.of<HeightPixel>(context).value;
  final colorScheme = Theme.of(context).colorScheme;

  return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      toolbarHeight: 80*hp,
      title: Row(children: <Widget>[
        SizedBox(width: 13*wp),
        Text('Activity',
            style:
            Theme.of(context).textTheme.headline4)
      ],
      ),
  );
}
