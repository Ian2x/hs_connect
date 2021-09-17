import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/explore/new_group/new_group_form.dart';
import 'package:hs_connect/screens/explore/new_group/new_group_image_2.dart';
import 'package:hs_connect/screens/explore/new_group/new_group_text_2.dart';
import 'package:hs_connect/screens/home/profile/profile_form.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:provider/provider.dart';

class NewGroup2 extends StatelessWidget {
  const NewGroup2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text('Your Profile'),
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              NewGroupText2(),
              NewGroupImage2(),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.pink[400],
                  ),
                  onPressed: () async {

                    if (newFile != null) {
                      // upload newFile
                      final downloadURL = await _images.uploadImage(file: newFile!);
                      setState(() {
                        newFileURL = downloadURL;
                      });
                    }

                    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                      setState(() => loading = true);
                      await GroupsDatabaseService().newGroup(
                        accessRestrictions: _accessRestriction!,
                        name: _name,
                        userId: user.uid,
                        image: newFileURL,
                        onValue: handleValue,
                        onError: handleError,
                      );


                    }


                  },
                  child: Text(
                    'Make group',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ));
  }
}
