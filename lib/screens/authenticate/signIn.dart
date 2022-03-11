import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/resetPassword.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/themeManager.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../shared/constants.dart';
import 'authButton.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  bool withPhone = true;
  bool isLoading = false;
  bool passwordHidden = true;
  bool numberValidated = false;

  // text field state
  String email = '';
  String password = '';
  String? phoneNumber;

  String? error;

  String authError = "Invalid username and password";

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: Colors.white, body: Loading(backgroundColor: Colors.white, spinColor: Color(0xff60676c)))
        : withPhone ? phoneSignIn() : emailSignIn();
  }

  Widget phoneSignIn() {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: myBackButtonIcon(context, overrideColor: ThemeNotifier.lightThemeOnSurface),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Stack(children: [
          SingleChildScrollView(
            child: Column(children: [
              SizedBox(height: 60),
              Text(
                'Login',
                style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
              ),
              SizedBox(height: 20),
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  if (mounted) {
                    setState(() {
                      phoneNumber = number.phoneNumber;
                    });
                  }
                  if (error != null) {
                    error = null;
                  }
                },
                onInputValidated: (bool value) {
                  if (mounted) {
                    setState(() => numberValidated = value);
                  }
                },
                selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.DIALOG,
                    showFlags: false,
                    leadingPadding: 0.0,
                    trailingSpace: false),
                ignoreBlank: false,
                textStyle: textTheme.headline6?.copyWith(color: Colors.black),
                selectorTextStyle: textTheme.headline6?.copyWith(color: Colors.black),
                formatInput: false,
                initialValue: PhoneNumber(isoCode: 'US'),
                keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                //inputBorder: OutlineInputBorder(gapPadding: 0.0),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.center,
                child: Text(
                  error ?? "We'll send a verification text. Standard rates apply.",
                  style: textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 14, height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 130),
            ]),
          ),
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width * 0.5 - 180,
            width: 360,
            child: AuthButton(
              buttonText: "Next",
              hasText: email != "" && password != "",
              onPressed: () async {
                if (email != "" && password != "") {
                  if (mounted) {
                    setState(() => isLoading = true);
                  }
                  dynamic result = await _auth.signInWithEmail(email, password);
                  if (!(result is User?)) {
                    if (mounted) {
                      setState(() {
                        error = authError;
                        isLoading = false;
                      });
                    }
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Wrapper()), (Route<dynamic> route) => false);
                  }
                }
                dismissKeyboard(context);
              },
            ),
          ),
        ]));
  }


  Widget emailSignIn() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: myBackButtonIcon(context, overrideColor: ThemeNotifier.lightThemeOnSurface),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Stack(children: [
          SingleChildScrollView(
            child: Column(children: [
              SizedBox(height: 60),
              Text(
                'Login',
                style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 28, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                error ?? "",
                style:
                Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 14, height: 1.3),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                        autocorrect: false,
                        style: Theme.of(context).textTheme.headline6?.copyWith(color: authPrimaryTextColor),
                        maxLines: null,
                        decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.headline6?.copyWith(color: authHintTextColor),
                            border: InputBorder.none,
                            hintText: "Email"),
                        onChanged: (val) {
                          if (mounted) {
                            setState(() => email = val);
                          }
                        }),
                    Divider(height: 0, thickness: 2, color: authHintTextColor),
                    SizedBox(height: 10),
                    TextField(
                        autocorrect: false,
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
                    Divider(height: 0, thickness: 2, color: authHintTextColor),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResetPassword()));
                },
                child: Text(
                  "Forgot password?",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(color: authPrimaryTextColor, fontSize: 14, height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 105),
            ]),
          ),
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width * 0.5 - 180,
            width: 360,
            child: AuthButton(
              buttonText: "Sign in",
              hasText: email != "" && password != "",
              onPressed: () async {
                if (email != "" && password != "") {
                  if (mounted) {
                    setState(() => isLoading = true);
                  }
                  dynamic result = await _auth.signInWithEmail(email, password);
                  if (!(result is User?)) {
                    if (mounted) {
                      setState(() {
                        error = authError;
                        isLoading = false;
                      });
                    }
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Wrapper()), (Route<dynamic> route) => false);
                  }
                }
                dismissKeyboard(context);
              },
            ),
          ),
        ]));
  }
}
