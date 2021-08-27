import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/new_post/post_form.dart';
import 'package:provider/provider.dart';

class NewPost extends StatelessWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Create a new_post'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
      ),
      body: Container(
        child: PostForm(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.school, size: 18.0),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: const Icon(Icons.add, size: 18.0),
              onPressed: () { print(userData); },
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
        ],
      ),
    );
  }
}
