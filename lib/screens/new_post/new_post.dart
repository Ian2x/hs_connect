import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/profile/profile.dart';
import 'package:hs_connect/screens/search/group_search.dart';
import 'package:hs_connect/screens/home/home.dart';
import 'package:hs_connect/screens/new_post/post_form.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/navbar.dart';
import 'package:provider/provider.dart';

class NewPost extends StatelessWidget {
  const NewPost({Key? key}) : super(key: key);

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
        title: Text('Create a new post'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
      ),
      body: Container(
        child: PostForm(),
      ),
      bottomNavigationBar: navbar(currentIndex: 2,),
    );
  }
}
