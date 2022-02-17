import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/themeManager.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/checkboxFormField.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:provider/provider.dart';

import 'authButton.dart';

class SignIn extends StatefulWidget {

  const SignIn({Key? key}) : super(key: key);


  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool passwordHidden = true;
  bool termsAccepted = false;

  // text field state
  String username = '';
  String password = '';

  String error = '';

  String authError = "Invalid username and password";
  String termsError = "Must read and agree to policies/terms";

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
        appBar: AppBar(leading: myBackButtonIcon(context, overrideColor: ThemeNotifier.lightThemeOnSurface), elevation: 0, backgroundColor: Colors.white,),
        body: Stack(
            children: [
              GestureDetector(
                onTap: ()=>dismissKeyboard(context),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child:
                            Column(
                              children: [
                                SizedBox(
                                  height: 70 *hp,
                                  child:
                                  Image.asset('assets/splash1cropped.png'),
                                ),
                                SizedBox(height: 15*hp),
                                Text(
                                  'Login',
                                  style: ThemeText.helvetica(fontWeight: FontWeight.w700, fontSize: 28*hp, color: Colors.black
                                  ),
                                ),
                                SizedBox(height: 10*hp),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 25*wp),
                                  child: Text("Enter your login credentials.",
                                    style: Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 14*hp, height: 1.3), textAlign: TextAlign.center,),
                                ),
                                error != '' ?
                                Container(
                                  height: 20*hp,
                                  alignment: Alignment.bottomCenter,
                                  child: Text(error,
                                    style: ThemeText.helvetica(fontWeight: FontWeight.w500, fontSize: 13*hp, color: Colors.black), textAlign: TextAlign.center),
                                )
                                : Container(height: 20*hp),
                                Container(
                                  padding:EdgeInsets.fromLTRB(20*wp,0,20*wp,0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                            autocorrect:false,
                                            style: Theme.of(context).textTheme.headline6?.copyWith(color: authPrimaryTextColor),
                                            maxLines: null,
                                            decoration: InputDecoration(
                                                hintStyle: Theme.of(context).textTheme.headline6?.copyWith(color: authHintTextColor),
                                                border: InputBorder.none,
                                                hintText: "Username"),
                                            onChanged: (val) {
                                              if (mounted) {
                                                setState(() => username = val);
                                              }
                                            }
                                        ),
                                        Divider(height:0, thickness: 2*hp, color: authHintTextColor),
                                        SizedBox(height:10*hp),
                                        TextFormField(
                                            autocorrect:false,
                                            style: Theme.of(context).textTheme.headline6?.copyWith(color: authPrimaryTextColor),
                                            decoration: InputDecoration(
                                                hintStyle: Theme.of(context).textTheme.headline6?.copyWith(color: authHintTextColor),
                                                border: InputBorder.none,
                                                suffixIcon: IconButton(
                                                  icon: passwordHidden ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                                                  iconSize: 17,
                                                  onPressed: () {
                                                    if (mounted) {
                                                      setState(() => passwordHidden = !passwordHidden);
                                                    }
                                                  },
                                                ),
                                                hintText: "Password"),
                                            obscureText: passwordHidden,

                                            onChanged: (val) {
                                              if (mounted) {
                                                setState(() => password = val);
                                              }
                                            }),
                                        Divider(height:0, thickness: 2*hp, color: authHintTextColor),
                                        SizedBox(height:20*hp),
                                        AuthCheckboxFormField(termsAccepted: termsAccepted, toggleTerms: (bool val) {
                                          if (error==termsError) {
                                            error = '';
                                          }
                                          if (mounted) {
                                            setState(()=> termsAccepted = val);
                                          }
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                                  SizedBox(height: 105*hp),
                                ],
                              )
                          ),
                        ]),
                  ),
              ),
              Positioned(
                bottom:0,
                left: MediaQuery.of(context).size.width * 0.5 - 70,
                width: 140,
                child: AuthButton(buttonText: "Sign in",
                  hasText: username!="" && password!="",
                  onPressed: () async {
                    if (!termsAccepted) {
                      if (mounted) {
                        setState(() => error = termsError);
                      }
                      return;
                    }
                    dismissKeyboard(context);
                    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                      if (mounted) {
                        setState(() => loading = true);
                      }
                      dynamic result = await _auth.signInWithUsernameAndPassword(username, password);
                      print(result);
                      if (!(result is User?)) {
                        if (mounted) {
                          setState(() {
                            error = authError;
                            loading = false;
                          });
                        }
                      } else {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => pixelProvider(context, child: Wrapper())), (Route<dynamic> route) => false);
                      }
                    }
                  },
                ),
              ),
            ]
    )
    );
  }
}
