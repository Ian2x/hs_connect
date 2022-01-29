import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/createMaterialColor.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Main2 extends StatelessWidget {
  const Main2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    {
      final user = Provider.of<User?>(context);
      return StreamProvider<UserData?>.value(
        value: user != null
            ? UserDataDatabaseService(currUserRef: FirebaseFirestore.instance.collection(C.userData).doc(user.uid))
            .userData
            : null,
        initialData: null,
        child: MaterialApp(
          home: Wrapper(),
          theme: ThemeData(
            brightness: Brightness.light,
            backgroundColor: Color(0xFFf2f2f2), // background
            colorScheme: ColorScheme(
              brightness: Brightness.light,
              background: Color(0xFFf4f4f4), // background grey / light grey
              onSurface: Color(0xFF000000), // black
              error: Color(0xFFb2b2b2),
              primaryVariant: Color(0xFF373a3d), // dark grey
              secondaryVariant: Color(0xFF137ef0), // darker secondary blue
              secondary: Color(0xFF13a1f0), // secondary blue
              surface: Color(0xFFffffff), // white
              primary: Color(0xFFa1a1a1), // medium grey
              onError: Color(0xFFc9c9c9), // light medium grey
              onSecondary: Color(0xFFff004d),// secondary red
              onPrimary: Color(0xFF000000),
              onBackground: Color(0xFF000000),
            ),
            primarySwatch: createMaterialColor(Color(0xFFA1A1A1)),// from primary color
            textTheme: TextTheme(
              headline1: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 93,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1.5
              ),
              headline2: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 58,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.5
              ),
              headline3: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 47,
                  fontWeight: FontWeight.w400
              ),
              headline4: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 33,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25
              ),
              headline5: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 23,
                  fontWeight: FontWeight.w400
              ),
              headline6: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15
              ),
              subtitle1: TextStyle(
                fontFamily: "Inter",
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.15,
              ),
              subtitle2: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1
              ),
              bodyText1: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5
              ),
              bodyText2: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25
              ),
              button: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.25
              ),
              caption: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.4
              ),
              overline: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5
              ),
            ),
            splashColor: Colors.transparent,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            /* dark theme settings */
          ),
          themeMode: ThemeMode.light,
        ),
      );
    }
  }
}
