import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/shared/pic_picker.dart';

class NewGroupImage2 extends StatefulWidget {
  const NewGroupImage2({Key? key}) : super(key: key);

  @override
  _NewGroupImage2State createState() => _NewGroupImage2State();
}

class _NewGroupImage2State extends State<NewGroupImage2> {
  final _formKey = GlobalKey<FormState>();

  void handleError(err) {
    setState(() {
      error = 'ERROR: something went wrong, possibly with username to email conversion';
    });
  }

  void handleValue(val) {
    loading = false;
    Navigator.pop(context);
  }

  // form values
  String error = '';
  bool loading = false;

  String? newFileURL;
  File? newFile;

  ImageStorage _images = ImageStorage();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    final userData = Provider.of<UserData?>(context);

    void setPic(File newFile2) {
      setState(() {
        newFile = newFile2;
      });
    }

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    } else {

      return SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              PicPicker(setPic: setPic, height: groupPicHeight, width: groupPicWidth),

            ],
          ),
        ),
      );
    }

    return Container();
  }
}
