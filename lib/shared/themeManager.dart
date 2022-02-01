import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hs_connect/shared/myStorageManager.dart';
import 'package:hs_connect/shared/tools/createMaterialColor.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Color(0xFF0A0A0A),
    // background
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xFF0A0A0A),
      // background grey / light grey
      onSurface: Color(0xFFe3e3e3),
      // black
      error: Color(0xFFb2b2b2),
      //light medium grey
      primaryVariant: Color(0xff151515),
      // postCard Grey
      secondaryVariant: Color(0xFF137ef0),
      // darker secondary blue
      secondary: Color(0xFF13a1f0),
      // secondary blue
      surface: Color(0xff000000),
      // black
      primary: Color(0xFFb2b2b2),
      // medium grey
      onError: Color(0xffdbdada),
      // light medium grey
      onSecondary: Color(0xFFff004d),
      // secondary red
      onPrimary: Color(0xFF000000),
      onBackground: Color(0xFF000000),
    ),
    primarySwatch: createMaterialColor(Color(0xFFA1A1A1)),
    // from primary color
    textTheme: TextTheme(
      headline1: TextStyle(fontFamily: "Inter", fontSize: 93, fontWeight: FontWeight.w300, letterSpacing: -1.5),
      headline2: TextStyle(fontFamily: "Inter", fontSize: 58, fontWeight: FontWeight.w300, letterSpacing: -0.5),
      headline3: TextStyle(fontFamily: "Inter", fontSize: 47, fontWeight: FontWeight.w400),
      headline4: TextStyle(fontFamily: "Inter", fontSize: 33, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      headline5: TextStyle(fontFamily: "Inter", fontSize: 23, fontWeight: FontWeight.w400),
      headline6: TextStyle(fontFamily: "Inter", fontSize: 19, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      subtitle1: TextStyle(
        fontFamily: "Inter",
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      subtitle2: TextStyle(fontFamily: "Inter", fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyText1: TextStyle(fontFamily: "Inter", fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyText2: TextStyle(fontFamily: "Inter", fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      button: TextStyle(fontFamily: "Inter", fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
      caption: TextStyle(fontFamily: "Inter", fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      overline: TextStyle(fontFamily: "Inter", fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
    ),
    splashColor: Colors.transparent,
  );

  final lightTheme = ThemeData(
    brightness: Brightness.light,
    backgroundColor: Color(0xFFf2f2f2),
    // background
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      background: Color(0xFFf4f4f4),
      // background grey / light grey
      onSurface: Color(0xFF000000),
      // black
      error: Color(0xFFb2b2b2),
      primaryVariant: Color(0xff60676c),
      // dark grey
      secondaryVariant: Color(0xFF137ef0),
      // darker secondary blue
      secondary: Color(0xFF13a1f0),
      // secondary blue
      surface: Color(0xFFffffff),
      // white
      primary: Color(0xFFa1a1a1),
      // medium grey
      onError: Color(0xffdbdada),
      // light medium grey
      onSecondary: Color(0xFFff004d),
      // secondary red
      onPrimary: Color(0xFF000000),
      onBackground: Color(0xFF000000),
    ),
    primarySwatch: createMaterialColor(Color(0xFFA1A1A1)),
    // from primary color
    textTheme: TextTheme(
      headline1: TextStyle(fontFamily: "Inter", fontSize: 93, fontWeight: FontWeight.w300, letterSpacing: -1.5),
      headline2: TextStyle(fontFamily: "Inter", fontSize: 58, fontWeight: FontWeight.w300, letterSpacing: -0.5),
      headline3: TextStyle(fontFamily: "Inter", fontSize: 47, fontWeight: FontWeight.w400),
      headline4: TextStyle(fontFamily: "Inter", fontSize: 33, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      headline5: TextStyle(fontFamily: "Inter", fontSize: 23, fontWeight: FontWeight.w400),
      headline6: TextStyle(fontFamily: "Inter", fontSize: 19, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      subtitle1: TextStyle(
        fontFamily: "Inter",
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      subtitle2: TextStyle(fontFamily: "Inter", fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      bodyText1: TextStyle(fontFamily: "Inter", fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyText2: TextStyle(fontFamily: "Inter", fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      button: TextStyle(fontFamily: "Inter", fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
      caption: TextStyle(fontFamily: "Inter", fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      overline: TextStyle(fontFamily: "Inter", fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
    ),
    splashColor: Colors.transparent,
  );

  late ThemeData _themeData;

  ThemeData getTheme() => _themeData;

  ThemeNotifier(BuildContext context) {
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    _themeData = brightness == Brightness.light ? lightTheme : darkTheme;
    MyStorageManager.readData('themeMode').then((value) {
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        this._themeData = lightTheme;
      } else {
        this._themeData = darkTheme;
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    MyStorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    MyStorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}
