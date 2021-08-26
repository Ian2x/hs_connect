import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:provider/provider.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key, required this.popProfile}) : super(key: key);

  final Function popProfile;

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  // form values
  String? _displayedName;
  String? _imageURL;
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    void handleError(err) {
      setState(() {
        error =
            'ERROR: something went wrong, possibly with username to email conversion';
      });
    }

    void handleValue(val) {
      loading = false;
      Navigator.pop(context);
    }

    return StreamBuilder<UserData>(
        stream: UserInfoDatabaseService(userId: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data!;

            return loading
                ? Loading()
                : Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Update your profile.',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          initialValue: userData.displayedName,
                          decoration: textInputDecoration,
                          validator: (val) {
                            if (val == null) return 'Error: null value';
                            if (val.isEmpty)
                              return 'Please enter a display name';
                            else
                              return null;
                          },
                          onChanged: (val) =>
                              setState(() => _displayedName = val),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          initialValue: userData.imageURL,
                          decoration: textInputDecoration,
                          validator: (val) {
                            if (val == null)
                              return 'Error: null value';
                            else
                              return null;
                          },
                          onChanged: (val) => setState(() => _imageURL = val),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.pink[400],
                            ),
                            onPressed: () async {
                              if (_formKey.currentState != null &&
                                  _formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                await UserInfoDatabaseService(userId: user.uid)
                                    .updateProfile(
                                  displayedName:
                                      _displayedName ?? userData.displayedName,
                                  imageURL: _imageURL ?? userData.imageURL,
                                  onValue: handleValue,
                                  onError: handleError,
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
          } else {
            return Loading();
          }
        });
  }
}
