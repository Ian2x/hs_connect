import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/services/auth.dart';
import 'package:hs_connect/Backend/services/known_domains_database.dart';
import 'package:hs_connect/Backend/shared/constants.dart';
import 'package:hs_connect/Backend/shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  const SignIn({Key? key, required this.toggleView}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String username = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign in to HS Connect'),
        actions: <Widget>[
          TextButton.icon(
              icon: Icon(Icons.person),
              label: Text('Register'),
              onPressed: () {
                widget.toggleView();
              })
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(children: <Widget>[
            SizedBox(height: 20.0),
            TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Username'),
                validator: (val) {
                  if (val == null) return 'Error: null value';
                  if (val.isEmpty)
                    return 'Enter username';
                  else
                    return null;
                },
                onChanged: (val) {
                  setState(() => username = val);
                }),
            SizedBox(height: 20.0),
            TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Password'),
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
                    print(username);
                    print(password);
                    setState(() => loading = true);
                    dynamic result = await _auth.signInWithUsernameAndPassword(username, password);

                    print(result);
                    if (result == null) {
                      setState(() {
                        error = 'Could not sign in with those credentials';
                        loading = false;
                      });
                    }
                  }
                },
                child: Text('Sign in', style: TextStyle(color: Colors.white))),
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
