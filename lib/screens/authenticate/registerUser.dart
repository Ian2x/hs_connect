import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

import 'authBar.dart';

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

  String authError = 'That username has already been taken.';
  String lengthError = 'Username and Password should be 6+ characters long.';

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;

    return loading
        ? Scaffold(
      backgroundColor: Colors.white,
      body: Loading(backgroundColor: Colors.white, spinColor: Color(0xff60676c))
    )
        : Scaffold(
      backgroundColor: Colors.white,
        body: Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100*hp,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: Gradients.blueRed(begin: Alignment.topLeft , end: Alignment.bottomRight),
                          ),
                          child: SizedBox(),
                        ),
                        SizedBox(height: 30*hp),
                        Center(
                            child:
                            Column(
                              children: [
                                SizedBox(
                                  height: 80 *hp,
                                  child:
                                  Image.asset('assets/sublogo1cropped.png'),
                                ),
                                SizedBox(height: 35*hp),
                                Text(
                                  'Make an Account',
                                  style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 28*hp, color: Colors.black
                                  ),
                                ),
                                SizedBox(height: 10*hp),
                                Text("Your username is only used for logging in.\n(No one else will see it)",
                                    style: Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 14), textAlign: TextAlign.center,),
                                Container(
                                  height: 40*hp,
                                  padding: EdgeInsets.symmetric(horizontal: 20*wp),
                                  alignment: Alignment.bottomCenter,
                                  child: error != null ? Text(
                                    error!, style: Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 12), textAlign: TextAlign.center) : Container()
                                ),
                                Container(
                                  padding:EdgeInsets.fromLTRB(20*wp,0,20*wp,0),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                          style: Theme.of(context).textTheme.headline6?.copyWith(color: Color(0xFFa1a1a1)),
                                          autocorrect:false,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                              hintStyle: Theme.of(context).textTheme.headline6?.copyWith(color: Color(0xffdbdada)),
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
                                      Divider(height:0, thickness: 2*hp, color: Color(0xffdbdada)),
                                      TextFormField(
                                          style: Theme.of(context).textTheme.headline6?.copyWith(color: Color(0xFFa1a1a1)),
                                          autocorrect:false,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              hintStyle: Theme.of(context).textTheme.headline6?.copyWith(color: Color(0xffdbdada)),
                                              border: InputBorder.none,
                                              hintText: "Password..."),
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
                                      Divider(height:0, thickness: 2*hp, color: Color(0xffdbdada)),
                                    ],
                                  ),
                                ),
                                  SizedBox(height: 120*hp),
                                ],
                              )
                          ),
                        ]),
                  ),
              ),
              Positioned(
                bottom:0,
                left:0,
                child: new AuthBar(buttonText: "Register",
                    onPressed: () async {
                        dismissKeyboard(context);
                        if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                        if (username.length < 6 || password.length < 6){
                          if (mounted) {
                            setState(() {
                                error = lengthError;
                            });
                          }
                          return;
                        }
                        if (_formKey.currentState != null && _formKey.currentState!.validate()
                        ) {
                          if (mounted) {
                            setState(() => loading = true);
                          }
                          dynamic result =
                              await _auth.registerWithUsernameAndPassword(username, password, widget.domain, widget.domainEmail);
                          if (result is User?) {
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => pixelProvider(context, child: Wrapper())), (Route<dynamic> route) => false);
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
                      }},),
              ),
            ])
    );
  }
}
