import 'package:flutter/material.dart';
import 'package:hs_connect/screens/home/new/newGroup/_newGroupForm.dart';

class NewGroup extends StatelessWidget {
  const NewGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
