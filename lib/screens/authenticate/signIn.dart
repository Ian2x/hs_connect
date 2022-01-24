import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
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

    final hp = getHp(context);
    final wp = getWp(context);
    return loading
        ? Scaffold(backgroundColor: ThemeColor.backgroundGrey, body: Loading())
        : Scaffold(
            backgroundColor: ThemeColor.white,
            body: Stack(
              children: [
                Positioned(
                  bottom:0,
                  right:0,
                  left:0,
                  child: AuthBar(buttonText: "Sign in", hp: hp, wp: wp,
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
                  padding: EdgeInsets.symmetric(vertical: 20*hp, horizontal: 50*wp),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      SizedBox(height: 78*hp),
                      Center(
                        child:
                        Column(
                          children: [
                            Container(
                              height: 62*hp,
                              width: 62*hp,
                              decoration: new BoxDecoration(
                                color: ThemeColor.secondaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: 26*hp),
                            Text("Sign in", style: ThemeText.inter(fontSize: 23*hp,
                              fontWeight: FontWeight.w700,
                              color: ThemeColor.black,
                            )),
                            SizedBox(height: 26*hp),
                          ],
                        )
                      ),
                        TextFormField(
                            autocorrect:false,
                            style: ThemeText.inter(
                            color: ThemeColor.mediumGrey,
                            fontSize: 18*hp,
                            //fontWeight: ,
                          ),
                          maxLines: null,
                          decoration: InputDecoration(
                              hintStyle: ThemeText.inter(
                                color: ThemeColor.mediumGrey,
                                fontSize: 18*hp,
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
                      Divider(height:20*hp, thickness: 2*hp, color: ThemeColor.lightMediumGrey),
                        TextFormField(
                            autocorrect:false,
                            style: ThemeText.inter(
                              color: ThemeColor.mediumGrey,
                              fontSize: 18*hp,
                              //fontWeight: ,
                            ),
                            decoration: InputDecoration(
                                hintStyle: ThemeText.inter(
                                  color: ThemeColor.mediumGrey,
                                  fontSize: 18*hp,
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
