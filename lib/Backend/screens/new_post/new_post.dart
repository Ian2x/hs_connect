import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/models/user_data.dart';
import 'package:hs_connect/Backend/screens/explore/explore.dart';
import 'package:hs_connect/Backend/screens/home/home.dart';
import 'package:hs_connect/Backend/screens/new_post/post_form.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/Widgets/OGnavbar.dart';

class NewPost extends StatelessWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Create a new post'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,

      ),
      body: Container(
        child: PostForm(),
      ),
      bottomNavigationBar: OGnavbar(),
    );
  }
}
