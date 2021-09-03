import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/screens/explore/new_group/new_group.dart';
import 'package:hs_connect/Backend/screens/explore/new_group/new_group_form.dart';
import 'package:hs_connect/Backend/screens/home/home.dart';
import 'package:hs_connect/Backend/screens/new_post/new_post.dart';

class Explore extends StatelessWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Explore'),
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
        child: Text('Explore page'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.school, size: 18.0),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home()),
                );
              },
            ),
            label: 'Home',
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
              onPressed: () {},
            ),
            label: 'Explore',
          ),
        ]
      ),
    );
  }
}
