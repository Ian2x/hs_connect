import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';

import '../../services/auth.dart';
import '../../shared/myStorageManager.dart';
import '../../shared/widgets/loading.dart';
import 'authButton.dart';

class RegisterPassword extends StatefulWidget {
  final String email;

  const RegisterPassword({Key? key, required this.email}) : super(key: key);

  @override
  _RegisterPasswordState createState() => _RegisterPasswordState();
}

class _RegisterPasswordState extends State<RegisterPassword> {
  final AuthService _auth = AuthService();

  // text field state
  String password = '';
  bool passwordHidden = true;
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return loading
        ? Loading(
            backgroundColor: Colors.white,
            spinColor: Colors.black,
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: myBackButtonIcon(
                context,
                overrideColor: Colors.black,
              ),
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Create a Password',
                          style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: TextField(
                              style: textTheme.headline6?.copyWith(color: authPrimaryTextColor),
                              autocorrect: false,
                              obscureText: passwordHidden,
                              decoration: InputDecoration(
                                  hintStyle: textTheme.headline6?.copyWith(color: authHintTextColor),
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
                                }
                              })),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        alignment: Alignment.topLeft,
                        child: Text(
                          error ?? "Password must be 6+ characters.",
                          style: textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 14, height: 1.3),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 160),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: MediaQuery.of(context).size.width * 0.5 - 180,
                  width: 360,
                  child: AuthButton(
                      buttonText: "Next",
                      hasText: password.length >= 6,
                      onPressed: () async {
                        if (password.length >= 6) {
                          if (mounted) {
                            setState(() => loading = true);
                          }
                          final tempIndex = widget.email.lastIndexOf('@');
                          final domain = widget.email.substring(tempIndex);
                          dynamic result = await _auth.registerUser(widget.email, password, domain);
                          if (result is User?) {
                            await MyStorageManager.saveData('showSignUp', true);
                          } else if (result is FirebaseAuthException) {
                            if (mounted) {
                              setState(() {
                                error = result.message ?? result.toString();
                                loading = false;
                              });
                            }
                          } else {
                            if (mounted) {
                              setState(() {
                                error = result.toString();
                                loading = false;
                              });
                            }
                          }
                        }
                      }),
                ),
              ],
            ),
          );
  }
}
