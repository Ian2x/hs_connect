import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hs_connect/main2.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/themeManager.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  const firebaseConfig = {
    apiKey: '<your-api-key>',
    authDomain: '<your-auth-domain>',
    databaseURL: '<your-database-url>',
    storageBucket: '<your-storage-bucket-url>'
  };
   */
  FlutterNativeSplash.removeAfter(initialization);

  await Firebase.initializeApp();
  runApp(MyApp());
}

void initialization(BuildContext context) async {
  await Future.delayed(const Duration(milliseconds: 3000), () {
    print('after 3 seconds');
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(context),
      child: StreamProvider<User?>.value(
          value: AuthService().user,
          initialData: null,
          child: Main2(),
      ),
    );
  }
}