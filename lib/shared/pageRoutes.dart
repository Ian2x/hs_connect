import 'package:flutter/material.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(builder: builder, maintainState: maintainState, settings: settings, fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

Widget pixelProvider(BuildContext context, {required Widget child}) {
  return Provider<HeightPixel>.value(
      value: HeightPixel(MediaQuery.of(context).size.height / 781.1),
      child: Provider<WidthPixel>.value(
          value: WidthPixel(MediaQuery.of(context).size.width / 392.7),
          child: child));
}