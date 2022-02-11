import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hs_connect/main2.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/themeManager.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


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

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Firebase.initializeApp();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterNativeSplash.removeAfter(launchDelay);

  getNotificationsPermissions();

  runApp(MyApp());
}

void launchDelay(BuildContext context) async {
  await Future.delayed(const Duration(milliseconds: 500), () {});
}

void getNotificationsPermissions() async {
  NotificationSettings origSettings = await FirebaseMessaging.instance.getNotificationSettings();
  if (origSettings.authorizationStatus==AuthorizationStatus.notDetermined) {
    NotificationSettings newSettings = await FirebaseMessaging.instance.requestPermission();
  }
}

/*Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}*/

class MyApp extends StatelessWidget {

  static final FirebaseMessaging messaging = FirebaseMessaging.instance;


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