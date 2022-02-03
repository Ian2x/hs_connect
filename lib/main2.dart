import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/themeManager.dart';
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
        child: Consumer<ThemeNotifier>(
          builder: (context, theme, _) => MaterialApp(
            theme: theme.getTheme(),
            /*themeMode: ThemeMode.system,
            theme: ThemeNotifier.lightTheme,
            darkTheme: ThemeNotifier.darkTheme,*/
            home: Wrapper(),
          ),
        ),
      );
    }
  }
}
