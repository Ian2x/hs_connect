import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/profile/profile.dart';
import 'package:hs_connect/screens/search/new_group/new_group.dart';
import 'package:hs_connect/screens/search/new_group/new_group_form.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/new_post/new_post.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class GroupSearch extends StatelessWidget {
  const GroupSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);

    if (user==null || userData==null) {
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
                MaterialPageRoute(
                    builder: (context) => NewGroup()),
              );
            },
          )
        ]
      ),
      body: Container(
        child: Column(children: <Widget>[
          Text('Explore page'),
          // TrendingFeed(),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 1,
          items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.school, size: 18.0),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.search_rounded, size: 18.0),
              onPressed: () {

              },
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.add, size: 18.0),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewPost()),
                );
              },
            ),
            label: 'Post',
          ),

          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.search_rounded, size: 18.0),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(profileId: user.uid)),
                );
              },
            ),
            label: 'Profile',
          ),
        ]
      ),
    );
  }
}
