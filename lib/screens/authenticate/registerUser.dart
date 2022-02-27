import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';

import '../../shared/myStorageManager.dart';
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(20,0,20,0),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        SizedBox(height: 30),
                        Text(
                          'Make an Account',
                          style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 28, color: Colors.black),
                        ),
                        SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                                autofocus:true,
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
                            SizedBox(height:20),
                            error != null ?
                            FittedBox(
                              child: Text(error!,
                                  style: ThemeText.quicksand(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black),
                                  textAlign: TextAlign.left),
                            ) :
                            Text(
                                "Your username is only used for logging in.\n(No one else will see it)",
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.copyWith(color: Colors.black, fontSize: 15, height: 1.5)),
                          ],
                        ),
                        SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: MediaQuery.of(context).size.width * 0.5 - 180,
                  width: 360,
                  child: new AuthButton(
                    buttonText: "Register",
                    hasText: username!="" && password!="",
                    onPressed: () async {
                      if (username!="" && password!=""){
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
                          if (result is User?) {
                            MyStorageManager.saveData('showSignUp', true);
                            if (mounted) {
                              setState(() => loading = false);
                            }
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => Wrapper()),
                                    (Route<dynamic> route) => false);
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
                      }
                    },
                  ),
                ),
              ]),
            ));
  }
}
