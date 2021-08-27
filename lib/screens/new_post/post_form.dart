import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:provider/provider.dart';

class PostForm extends StatefulWidget {
  const PostForm({Key? key}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();

  // form values
  String _text = '';
  String? _imageURL;
  String _groupId = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    final userData = Provider.of<UserData>(context);

    void handleError(err) {
      setState(() {
        error =
        'ERROR: failed to create new post';
      });
    }

    void handleValue(val) {
      loading = false;
      Navigator.pop(context);
    }

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    } else {
      return loading
          ? Loading()
          : Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Text(
              'Create a new post',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            Text('Post text'),
            TextFormField(
              initialValue: '',
              decoration: textInputDecoration,
              validator: (val) {
                if (val == null) return 'Error: null value';
                if (val.isEmpty)
                  return 'Can\'t create an empty post';
                else
                  return null;
              },
              onChanged: (val) =>
                  setState(() => _text = val),
            ),
            SizedBox(height: 20.0),
            Text('(optional) Image URL'),
            TextFormField(
              initialValue: '',
              decoration: textInputDecoration,
              validator: (val) {
                if (val == null)
                  return 'Error: null value';
                else
                  return null;
              },
              onChanged: (val) => setState(() => _imageURL = val),
            ),
            SizedBox(height: 20.0),

            DropdownButtonFormField<String>(
              decoration: textInputDecoration,
              value: _groupId!='' ? _groupId : null,
              items: userData.userGroups.map((userGroup) {
                return DropdownMenuItem(
                  value: userGroup.userGroup as String,
                  child: Text('${userGroup.userGroup}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _groupId = val!),
            ),

            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink[400],
                ),
                onPressed: () async {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    await PostsDatabaseService(userId: user.uid)
                        .newPost(text: _text, imageURL: _imageURL, groupId: _groupId,
                    );
                  }
                },
                child: Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                )),
            SizedBox(height: 12.0),
            Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 14.0),
            )
          ],
        ),
      );
    }
  }
}
