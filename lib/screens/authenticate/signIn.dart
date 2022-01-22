import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/loading.dart';

import 'authBar.dart';

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

    double unit = MediaQuery.of(context).size.height/10;

    return loading
        ? Scaffold(backgroundColor: ThemeColor.backgroundGrey, body: Loading())
        : Scaffold(
            backgroundColor: ThemeColor.white,
            body: Stack(
              children: [
                Positioned(
                  bottom:0,
                  left:0,
                  child: AuthBar(buttonText: "Sign in",
                    onPressed: () async {
                      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                        if (mounted) {
                          setState(() => loading = true);
                        }
                        dynamic result = await _auth.signInWithUsernameAndPassword(username, password);
                        if (!(result is User?)) {
                          if (mounted) {
                            setState(() {
                              error = 'Could not sign in with those credentials';
                              loading = false;
                            });
                          }
                        }
                      }
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                  child: Form(
                    key: _formKey,
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      SizedBox(height: unit),
                      Center(
                        child:
                        Column(
                          children: [
                            Container(
                              height: unit*.8,
                              width: unit * .8,
                              decoration: new BoxDecoration(
                                color: ThemeColor.secondaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: unit/3),
                            Text("Sign in", style: ThemeText.inter(fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: ThemeColor.black,
                            )),
                            SizedBox(height: unit/3),
                          ],
                        )
                      ),
                      TextFormField(
                        autocorrect:false,
                        style: TextStyle(
                          color: ThemeColor.mediumGrey,
                          fontSize: 18,
                          //fontWeight: ,
                        ),
                        maxLines: null,
                        decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: ThemeColor.mediumGrey,
                              fontSize: 18,
                              //fontWeight: ,
                            ),
                            border: InputBorder.none,
                            hintText: "Username"),
                          validator: (val) {
                            if (val == null) return 'Error: null value';
                            if (val.isEmpty)
                              return 'Enter username';
                            else
                              return null;
                          },
                          onChanged: (val) {
                            if (mounted) {
                              setState(() => username = val);
                            }
                        }
                      ),
                      Divider(height:20, thickness: 2, color: ThemeColor.lightMediumGrey),
                        TextFormField(
                            autocorrect:false,
                            style: TextStyle(
                              color: ThemeColor.mediumGrey,
                              fontSize: 18,
                              //fontWeight: ,
                            ),
                            decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  color: ThemeColor.mediumGrey,
                                  fontSize: 18,
                                  //fontWeight: ,
                                ),
                                border: InputBorder.none,
                                hintText: "Password"),
                            obscureText: true,
                            validator: (val) {
                              if (val == null) return 'Error: null value';
                              if (val.length < 1)
                                return 'Password is empty';
                              else
                                return null;
                            },
                            onChanged: (val) {
                              if (mounted) {
                                setState(() => password = val);
                              }
                            }),
                      Divider(height:20, thickness: 2, color: ThemeColor.lightMediumGrey),
                      SizedBox(height: 20.0),
                      TextButton(
                          child: Text('Register here',
                              style: ThemeText.regularSmall(fontSize: 16, color: ThemeColor.secondaryBlue)),
                          onPressed: () {
                          widget.toggleView();
                      }),
                      SizedBox(height: 12.0),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                      Container(height:50, color: Colors.black),
                    ]),
                  ),
                ),
              ],
            ),
          );
  }
}
