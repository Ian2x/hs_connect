import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
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
            padding: EdgeInsets.fromLTRB(15.0, 30.0,15.0,0.0), //TODO May need to adjust to phone height?
            constraints: BoxConstraints.expand(),
            child: PostForm(),
          ),
          /*Positioned(
            right: 0,
            bottom: 0,
            child: postBar(),
          )*/
        ],
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 0,
      ),
    );
  }
}
