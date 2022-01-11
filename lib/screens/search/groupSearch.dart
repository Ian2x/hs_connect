import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/new/newGroup/_newGroup.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:provider/provider.dart';

class GroupSearch extends StatelessWidget {
  const GroupSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);

    if (user == null || userData == null) {
      return Loading();
    }

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
          title: Text('Group Search Bar... '),
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.settings),
              label: Text('Make a group'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewGroup()),
                );
              },
            )
          ]),
      body: Container(
        child: Column(children: <Widget>[
          Text('Explore page'),
          // TrendingFeed(),
        ]),
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 1,
      ),
    );
  }
}
