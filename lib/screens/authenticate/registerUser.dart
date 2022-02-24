import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myOutlinedButton.dart';
import 'package:tuple/tuple.dart';

import 'authButton.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({Key? key, required this.domain, required this.domainEmail}) : super(key: key);

  final String domain;
  final String domainEmail;

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

  String? error;
  bool passwordHidden = true;

  static const String authError = 'That username has already been taken.';
  static const String lengthError = 'Username and Password should be \n 6+ characters long.';

  @override
  Widget build(BuildContext context) {

    return loading
        ? Scaffold(
            backgroundColor: Colors.white, body: Loading(backgroundColor: Colors.white, spinColor: Color(0xff60676c)))
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            body: GestureDetector(
              onTap: () => dismissKeyboard(context),
              child: Stack(children: [
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Center(
                          child: Column(
                        children: [
                          SizedBox(
                            height: 70,
                            child: Image.asset('assets/Splash2.png'),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Make an Account',
                            style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 28, color: Colors.black),
                          ),
                          SizedBox(height: 20),
                          error != null ?
                          FittedBox(
                            child: Text(error!,
                                style: ThemeText.quicksand(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black),
                                textAlign: TextAlign.center),
                          ) :
                          Text(
                              "Your username is only used for logging in.\n(No one else will see it)",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(color: Colors.black, fontSize: 15, height: 1.5)),
                          SizedBox(height:15),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Column(
                              children: [
                                TextFormField(
                                    style: Theme.of(context).textTheme.headline6?.copyWith(color: authPrimaryTextColor),
                                    autocorrect: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                        hintStyle:
                                            Theme.of(context).textTheme.headline6?.copyWith(color: authHintTextColor),
                                        border: InputBorder.none,
                                        hintText: "Login Username..."),
                                    onChanged: (val) {
                                      if (mounted) {
                                        setState(() => username = val);
                                        if (username.length >= 6) {
                                          if (mounted) {
                                            setState(() {
                                              error = null;
                                            });
                                          }
                                        }
                                      }
                                    }),
                                Divider(height: 0, thickness: 2, color: authHintTextColor),
                                TextFormField(
                                    style: Theme.of(context).textTheme.headline6?.copyWith(color: authPrimaryTextColor),
                                    autocorrect: false,
                                    obscureText: passwordHidden,
                                    decoration: InputDecoration(
                                        hintStyle:
                                            Theme.of(context).textTheme.headline6?.copyWith(color: authHintTextColor),
                                        border: InputBorder.none,
                                        hintText: "Password...",
                                        suffixIcon: IconButton(
                                          icon: passwordHidden ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                                          iconSize: 17,
                                          onPressed: () {
                                            if (mounted) {
                                              setState(() => passwordHidden = !passwordHidden);
                                            }
                                          },
                                        )),
                                    onChanged: (val) {
                                      if (mounted) {
                                        setState(() => password = val);
                                        if (val.length >= 6) {
                                          if (mounted) {
                                            setState(() {
                                              error = null;
                                            });
                                          }
                                        }
                                      }
                                    }),
                                Divider(height: 0, thickness: 2, color: Color(0xffdbdada)),
                              ],
                            ),
                          ),
                          SizedBox(height: 120),
                        ],
                      )),
                    ]),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: MediaQuery.of(context).size.width * 0.5 - 70,
                  width: 140,
                  child: new AuthButton(
                    buttonText: "Register",
                    hasText: username!="" && password!="",
                    onPressed: () async {
                      dismissKeyboard(context);
                      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                        if (username.length < 6 || password.length < 6) {
                          if (mounted) {
                            setState(() {
                              error = lengthError;
                            });
                          }
                          return;
                        }
                        if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                          if (mounted) {
                            setState(() => loading = true);
                          }
                          dynamic result = await _auth.registerWithUsernameAndPassword(
                              username, password, widget.domain, widget.domainEmail);
                          if (result is Tuple4<User?, String, int, String>) {
                            if (mounted) {
                              setState(() => loading = false);
                            }
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return new AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20))),
                                  backgroundColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(vertical:10),
                                  title: Text(
                                    "You're user number " +
                                        result.item3.toString() +
                                        " from " +
                                        result.item4 +
                                        ". We gave you the name:",
                                    textAlign: TextAlign.center,
                                    style: ThemeText.quicksand(fontSize: 15, color: Colors.black),
                                  ),
                                  content: Container(
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          result.item2,
                                          style: ThemeText.quicksand(fontSize: 20, color: Colors.black),
                                        ),
                                        SizedBox(height: 25),
                                        MyOutlinedButton(
                                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                                          onPressed: () {
                                            Navigator.of(context).pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) => Wrapper()),
                                                (Route<dynamic> route) => false);
                                          },
                                          gradient: Gradients.blueRed(
                                              begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                          borderRadius: 30,
                                          backgroundColor: Colors.white,
                                          child: Text(
                                            "Continue",
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: ThemeText.quicksand(
                                                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(height: 10)
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (result is FirebaseAuthException && result.code == 'email-already-in-use') {
                            if (mounted) {
                              setState(() {
                                error = authError;
                                loading = false;
                              });
                            }
                          } else if (result is FirebaseAuthException) {
                            if (mounted) {
                              setState(() {
                                String errorMsg = 'Error: ';
                                if (result.message != null) errorMsg += result.message!;
                                error = errorMsg;
                                loading = false;
                              });
                            }
                          } else {
                            if (mounted) {
                              setState(() {
                                error = "Error: " + result.toString();
                                loading = false;
                              });
                            }
                          }
                        }
                      }
                    },
                  ),
                ),
              ]),
            ));
  }
}
