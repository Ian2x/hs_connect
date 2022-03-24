import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'postForm.dart';
import 'dart:io';

class NewPost extends StatelessWidget {
  final String? initialURL;
  final File? initialImage;
  const NewPost({Key? key, this.initialURL, this.initialImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context, listen: false);

    if (userData == null) {
      return Loading();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        constraints: BoxConstraints.expand(),
        child: PostForm(currUserData: userData, initialURL: initialURL, initialImage: initialImage,),
      ),
    );
  }
}
