import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

import 'authBar.dart';

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
  String username = 'username';
  String password = '';

  String error='';

  String authTakenErr ='';
  String usernameError = '';
  String passwordError = '';

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return loading
        ? Scaffold(
      backgroundColor: colorScheme.background,
      body: Loading()
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
                          height: 110*hp,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: Gradients.blueRed(begin: Alignment.topLeft , end: Alignment.bottomRight),
                          ),
                          child: SizedBox(),
                        ),
                        SizedBox(height: 10*hp),
                        Row(
                          children: [
                            SizedBox(width: 10*hp),
                            TextButton(
                                onPressed: (){
                                },
                                child:Text(
                                  "Cancel",
                                  style: ThemeText.inter(fontWeight: FontWeight.normal,
                                      fontSize: 16*hp, color: Colors.grey),
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: 15*hp),
                        Center(
                            child:
                            Column(
                              children: [
                                SizedBox(
                                  height: 80 *hp,
                                  child:
                                  Image.asset('assets/logo1background.png'),
                                ),
                                SizedBox(height: 15*hp),
                                Text(
                                  'Make an Account',
                                  style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 28*hp, color: Colors.black //TODO: Convertto HP
                                  ),
                                ),
                                SizedBox(height: 8*hp),
                                usernameError != '' || passwordError != '' ?
                                    Column(
                                      children: [
                                        Text("Username and Password should be 6+ characters long.",
                                            style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.onSurface, fontSize: 12)),
                                        authTakenErr != '' ?
                                          Text(authTakenErr,
                                            style: Theme.of(context).textTheme.subtitle1?.copyWith
                                              (color: colorScheme.onSurface, fontSize: 14)) : Container(),
                                        ],
                                    ) :
                                    Text("Your username is only for logging in.",
                                    style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.onSurface, fontSize: 14)),
                                SizedBox(height: 25*hp),
                                Container(
                                  padding:EdgeInsets.fromLTRB(20.0,0,20,0),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                          style: Theme.of(context).textTheme.headline6?.copyWith(color: colorScheme.primary),
                                          autocorrect:false,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              hintStyle: Theme.of(context).textTheme.headline6?.copyWith(color: colorScheme.onError),
                                              border: InputBorder.none,
                                              hintText: "Login Username..."),
                                          validator: (val) {
                                            setState(() {
                                              if (val == null || val.length <6)
                                              {
                                                usernameError = "Enter a username 6+ characters long";
                                              }
                                            });
                                          },
                                          onChanged: (val) {
                                            if (mounted) {
                                              setState(() => username = val);
                                            }
                                          }),
                                      Divider(height:8*hp, thickness: 2*hp, color: colorScheme.onError),
                                      TextFormField(
                                          style: Theme.of(context).textTheme.headline6?.copyWith(color: colorScheme.primary),
                                          autocorrect:false,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              hintStyle: Theme.of(context).textTheme.headline6?.copyWith(color: colorScheme.onError),
                                              border: InputBorder.none,
                                              hintText: "Password..."),
                                          validator: (val) {
                                            setState(() {
                                              if (val == null || val.length <6)
                                              {
                                                passwordError = "Enter a password 6+ characters long";
                                              }
                                            });
                                          },
                                          onChanged: (val) {
                                            if (mounted) {
                                              setState(() => password = val);
                                            }
                                          }),
                                      Divider(height:8*hp, thickness: 2*hp, color: colorScheme.onError),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 100*hp),
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
                        if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                          if (mounted) {
                            setState(() => loading = true);
                          }
                          dynamic result =
                              await _auth.registerWithUsernameAndPassword(username, password, widget.domain);

                          if (result is User?) {
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => pixelProvider(context, child: Wrapper())), (Route<dynamic> route) => false);
                          } else if (result is FirebaseAuthException && result.code == 'email-already-in-use') {
                            if (mounted) {
                              setState(() {
                                authTakenErr = 'Username already in use.';
                                loading = false;
                              });
                            }
                          } else if (result is FirebaseAuthException) {
                            String errorMsg = '';
                            if (result.message != null) errorMsg += result.message!;
                            errorMsg +=
                                'If you think this is a mistake, please contact us at ___ for support. [Error Code: ' +
                                    result.code +
                                    ']';
                            error = errorMsg;
                            loading = false;
                          } else {
                            if (mounted) {
                              setState(() {
                                error = 'ERROR: [' + result.toString() + ']. Please contact us at ___ for support.';
                                loading = false;
                              });
                            }
                          }
                        }
                      },),
              ),
            ])
    );
  }
}
