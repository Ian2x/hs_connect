import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hs_connect/shared/myStorageManager.dart';
import 'package:hs_connect/shared/tools/createMaterialColor.dart';

class ThemeNotifier with ChangeNotifier {
  static const darkThemeOnSurface = Color(0xffffffff); // DBDBDBFF
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Color(0xff262626),
    // background
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      background: Color(0xff242424),
      onSurface: darkThemeOnSurface,
      //Color(0xffd4d3d3),
      error: Color(0xff4d4d4d),
      primaryContainer: Color(0xff818181),
      secondaryContainer: Color(0xff3f99ee),
      secondary: Color(0xff2992f4),
      surface: Color(0xff0c0c0c),
      primary: Color(0xffa1a1a1),
      onError: Color(0xff353636),
      onSecondary: Color(0xffff004d),
      onPrimary: Color(0xff000000),
      onBackground: Color(0xff000000),
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
      background: Color(0xfff4f4f4),
      // background grey / light grey
      onSurface: lightThemeOnSurface,
      // black
      error: Color(0xffb2b2b2),
      primaryContainer: Color(0xffd7d7d7),
      // dark grey
      secondaryContainer: Color(0xff1186f3),
      // darker secondary blue
      secondary: Color(0xff2992f4),
      // secondary blue
      surface: Color(0xffffffff),
      // white
      primary: Color(0xffa1a1a1),
      // medium grey
      onError: Color(0xffdbdada),
      // light medium grey
      onSecondary: Color(0xffff004d),
      // secondary red
      onPrimary: Color(0xff000000),
      onBackground: Color(0xff000000),
    ),
    primarySwatch: createMaterialColor(Color(0xFFA1A1A1)),
    // from primary color
    textTheme: myTextTheme.apply(bodyColor: lightThemeOnSurface, displayColor: lightThemeOnSurface),
    splashColor: Colors.transparent,
  );

  static const myTextTheme = TextTheme(
    headline1: TextStyle(fontFamily: "Quicksand", fontSize: 93, fontWeight: FontWeight.w400, letterSpacing: -1.5),
    headline2: TextStyle(fontFamily: "Quicksand", fontSize: 58, fontWeight: FontWeight.w400, letterSpacing: -0.5),
    headline3: TextStyle(fontFamily: "Quicksand", fontSize: 47, fontWeight: FontWeight.w500),
    headline4: TextStyle(fontFamily: "Quicksand", fontSize: 33, fontWeight: FontWeight.w500, letterSpacing: 0.25),
    headline5: TextStyle(fontFamily: "Quicksand", fontSize: 23, fontWeight: FontWeight.w500),
    headline6: TextStyle(fontFamily: "Quicksand", fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: 0.15),
    subtitle1: TextStyle(
      fontFamily: "Quicksand",
      fontSize: 16,
      fontWeight: FontWeight.w600, // boosted form w500
      letterSpacing: 0.15,
    ),
    subtitle2: TextStyle(fontFamily: "Quicksand", fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    bodyText1: TextStyle(fontFamily: "Quicksand", fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5), // boosted from w500
    bodyText2: TextStyle(fontFamily: "Quicksand", fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.25), // boosted from w500
    button: TextStyle(fontFamily: "Quicksand", fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.25),
    caption: TextStyle(fontFamily: "Quicksand", fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.4),
    overline: TextStyle(fontFamily: "Quicksand", fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5),
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
      } else if (value == 'dark') {
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
