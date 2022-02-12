import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'postForm.dart';

class NewPost extends StatelessWidget {
  const NewPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Loading();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:  Container(
          constraints: BoxConstraints.expand(),
          child: PostForm(userData: userData),
        ),
      );
  }
}
