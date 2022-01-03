import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/new/newPost/postBar.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/navigationBar.dart';
import 'package:provider/provider.dart';
import 'PostForm.dart';

class NewPost extends StatelessWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);

    if (user == null || userData == null) {
      return Loading();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            constraints: BoxConstraints.expand(),
            child: PostForm(),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: postBar(),
          )
        ],
      ),
      bottomNavigationBar: navigationBar(
        currentIndex: 2,
      ),
    );
  }
}
