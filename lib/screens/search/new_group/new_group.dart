import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/search/new_group/new_group_form.dart';
import 'package:hs_connect/screens/profile/profile_form.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:provider/provider.dart';

class NewGroup extends StatelessWidget {
  const NewGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Your Profile'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
      ),
      body: Container(
        child: NewGroupForm(),
      ),
    );
  }
}
