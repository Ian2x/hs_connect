import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Main2 extends StatefulWidget {
  const Main2({Key? key}) : super(key: key);

  @override
  _Main2State createState() => _Main2State();
}

class _Main2State extends State<Main2> {

  @override
  Widget build(BuildContext context) {


    final user = Provider.of<User?>(context);

    return StreamProvider<UserData?>.value(
      value: UserDataDatabaseService(userRef: user!=null ? FirebaseFirestore.instance.collection('userData').doc(user.uid) : null).userData,
      initialData: null,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}