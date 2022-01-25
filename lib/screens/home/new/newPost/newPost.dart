import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'PostForm.dart';

class NewPost extends StatelessWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Loading();
    }

    final hp = getHp(context);
    final wp = getWp(context);


    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(15*wp, 30*hp,15*wp,0*hp),
            constraints: BoxConstraints.expand(),
            child: PostForm(userData: userData, hp: hp, wp: wp),
          ),
        ],
      ),
    );
  }
}
