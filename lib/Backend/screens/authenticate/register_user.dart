import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/screens/home/home.dart';
import 'package:hs_connect/Backend/screens/wrapper.dart';
import 'package:hs_connect/Backend/services/auth.dart';
import 'package:hs_connect/Backend/shared/constants.dart';
import 'package:hs_connect/Backend/shared/loading.dart';
import 'package:provider/provider.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({Key? key, required this.domain}) : super(key: key);

  final String domain;

  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String username = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            appBar: AppBar(
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
              title: Text('Your email has been verified! Sign up now!'),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  SizedBox(height: 20.0),
                  TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Username'),
                      validator: (val) {
                        if (val == null) return 'Error: null value';
                        if (val.isEmpty)
                          return 'Enter a username';
                        else
                          return null;
                      },
                      onChanged: (val) {
                        setState(() => username = val);
                      }),
                  SizedBox(height: 20.0),
                  TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Password'),
                      obscureText: true,
                      validator: (val) {
                        if (val == null) return 'Error: null value';
                        if (val.length < 6)
                          return 'Enter a password 6+ chars long';
                        else
                          return null;
                      },
                      onChanged: (val) {
                        setState(() => password = val);
                      }),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.pink[400],
                      ),
                      onPressed: () async {
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          setState(() => loading = true);

                          dynamic result =
                              await _auth.registerWithUsernameAndPassword(
                                  username, password, widget.domain);
                          if (result == null) {
                            setState(() {
                              error =
                                  'ERROR: something went wrong, possibly with username to email conversion';
                              loading = false;
                            });
                          } else {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => Wrapper()));
                          }
                        }
                      },
                      child: Text('Register',
                          style: TextStyle(color: Colors.white))),
                  SizedBox(height: 12.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  )
                ]),
              ),
            ),
          );
  }
}
