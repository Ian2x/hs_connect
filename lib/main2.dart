import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Main2 extends StatelessWidget {
  const Main2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            primaryColor: ThemeColor.secondaryBlue,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: ThemeColor.darkGrey,
              selectionColor: ThemeColor.darkGrey,
              selectionHandleColor: ThemeColor.darkGrey,
            ),
            textTheme: TextTheme(
              headline1: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 93,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1.5
              ),
              headline2: TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.5
              ),
              headline3: TextStyle(
                  fontSize: 47,
                  fontWeight: FontWeight.w400
              ),
              headline4: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25
              ),
              headline5: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w400
              ),
              headline6: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15
              ),
              subtitle1: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.15,
              ),
              subtitle2: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1
              ),
              bodyText1: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5
              ),
              bodyText2: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25
              ),
              button: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.25
              ),
              caption: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.4
              ),
              overline: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5
              ),
            ),
            splashColor: Colors.transparent,
            backgroundColor: ThemeColor.backgroundGrey,
            dividerColor: ThemeColor.lightGrey,
            scaffoldBackgroundColor: ThemeColor.white,
            hintColor: ThemeColor.mediumGrey,
            unselectedWidgetColor: ThemeColor.mediumGrey,
            //primaryColorDark:
            //color: ThemeColor.mediumGrey,
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