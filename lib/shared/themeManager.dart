import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hs_connect/shared/myStorageManager.dart';
import 'package:hs_connect/shared/tools/createMaterialColor.dart';

class ThemeNotifier with ChangeNotifier {

  static const darkThemeOnSurface = Color(0xffdbdbdb);
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Color(0xff262626),
    // background
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xff262626),
      onSurface: darkThemeOnSurface, //Color(0xffd4d3d3),
      error: Color(0xFF4d4d4d),
      primaryVariant: Color(0xffbab9b9),
      secondaryVariant: Color(0xFF137ef0),
      secondary: Color(0xFF13a1f0),
      surface: Color(0xff131313),
      primary: Color(0xffa1a1a1),
      onError: Color(0xff353636),
      onSecondary: Color(0xFFff004d),
      onPrimary: Color(0xFF000000),
      onBackground: Color(0xFF000000),
    ),
    primarySwatch: createMaterialColor(Color(0xFFA1A1A1)),
    // from primary color
    textTheme: myTextTheme.apply(bodyColor: darkThemeOnSurface, displayColor: darkThemeOnSurface),
    splashColor: Colors.transparent,
  );

  static const lightThemeOnSurface = Color(0xFF000000);
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    backgroundColor: Color(0xFFf4f4f4),
    // background
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      background: Color(0xFFf4f4f4), // background grey / light grey
      onSurface: lightThemeOnSurface, // black
      error: Color(0xFFb2b2b2),
      primaryVariant: Color(0xff60676c), // dark grey
      secondaryVariant: Color(0xFF137ef0), // darker secondary blue
      secondary: Color(0xFF13a1f0), // secondary blue
      surface: Color(0xFFffffff), // white
      primary: Color(0xFFa1a1a1), // medium grey
      onError: Color(0xffdbdada), // light medium grey
      onSecondary: Color(0xFFff004d), // secondary red
      onPrimary: Color(0xFF000000),
      onBackground: Color(0xFF000000),
    ),
    primarySwatch: createMaterialColor(Color(0xFFA1A1A1)),
    // from primary color
    textTheme: myTextTheme.apply(bodyColor: lightThemeOnSurface, displayColor: lightThemeOnSurface),
    splashColor: Colors.transparent,
  );

  static const myTextTheme = TextTheme(
    headline1: TextStyle(fontFamily: "HelveticalNeue", fontSize: 93, fontWeight: FontWeight.w300, letterSpacing: -1.5),
    headline2: TextStyle(fontFamily: "HelveticalNeue", fontSize: 58, fontWeight: FontWeight.w300, letterSpacing: -0.5),
    headline3: TextStyle(fontFamily: "HelveticalNeue", fontSize: 47, fontWeight: FontWeight.w400),
    headline4: TextStyle(fontFamily: "HelveticalNeue", fontSize: 33, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    headline5: TextStyle(fontFamily: "HelveticalNeue", fontSize: 23, fontWeight: FontWeight.w400),
    headline6: TextStyle(fontFamily: "HelveticalNeue", fontSize: 19, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    subtitle1: TextStyle(
      fontFamily: "HelveticalNeue",
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
    ),
    subtitle2: TextStyle(fontFamily: "HelveticalNeue", fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyText1: TextStyle(fontFamily: "HelveticalNeue", fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyText2: TextStyle(fontFamily: "HelveticalNeue", fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    button: TextStyle(fontFamily: "HelveticalNeue", fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
    caption: TextStyle(fontFamily: "HelveticalNeue", fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    overline: TextStyle(fontFamily: "HelveticalNeue", fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
  );

  late ThemeData _themeData;

  ThemeData getTheme() => _themeData;

  ThemeNotifier(BuildContext context) {
    var brightness = SchedulerBinding.instance?.window.platformBrightness;
    this._themeData = brightness == Brightness.dark ? darkTheme : lightTheme;
    notifyListeners();

    MyStorageManager.readData('themeMode').then((value) {
      if (value == 'light') {
        this._themeData = lightTheme;
        notifyListeners();
      } else if (value == 'dark'){
        this._themeData = darkTheme;
        notifyListeners();
      }
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
