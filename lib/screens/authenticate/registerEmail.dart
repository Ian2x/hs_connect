import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/screens/authenticate/waitVerification.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/checkboxFormField.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:provider/provider.dart';

import 'authBar.dart';

class RegisterEmail extends StatefulWidget {
  final Function toggleView;

  const RegisterEmail({Key? key, required this.toggleView}) : super(key: key);

  @override
  _RegisterEmailState createState() => _RegisterEmailState();
}

class _RegisterEmailState extends State<RegisterEmail> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String? error;

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final textTheme = Theme.of(context).textTheme;

    return loading
        ? Scaffold(
            backgroundColor: Colors.white, body: Loading(backgroundColor: Colors.white, spinColor: Color(0xff60676c)))
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: myBackButtonIcon(context),
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            body: GestureDetector(
              onTap: () => dismissKeyboard(context),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          child: Center(
                              child: Column(
                            children: [
                              SizedBox(
                                height: 70 * hp,
                                child: Image.asset('assets/splash1cropped.png'),
                              ),
                              SizedBox(height: 15 * hp),
                              Text(
                                'Sign Up',
                                style: ThemeText.inter(
                                    fontWeight: FontWeight.w700, fontSize: 28 * hp, color: Colors.black),
                              ),
                              SizedBox(height: 10 * hp),
                              Text(
                                "We'll send you an email to verify your school.",
                                style:
                                    textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 14 * hp, height: 1.3),
                                textAlign: TextAlign.center,
                              ),
                              Container(
                                  height: 40 * hp,
                                  padding: EdgeInsets.symmetric(horizontal: 20 * wp),
                                  alignment: Alignment.bottomCenter,
                                  child: error != null
                                      ? Text(error!,
                                          style: ThemeText.inter(
                                              fontWeight: FontWeight.w500, fontSize: 13 * hp, color: Colors.black),
                                          textAlign: TextAlign.center)
                                      : Container())
                            ],
                          )),
                        ),
                        Form(
                          key: _formKey,
                          child: Container(
                              padding: EdgeInsets.fromLTRB(20 * wp, 0, 20 * wp, 0),
                              child: Column(
                                children: [
                                  TextField(
                                    autocorrect: false,
                                    style: textTheme.headline6?.copyWith(color: authPrimaryTextColor),
                                    maxLines: null,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        hintStyle: textTheme.headline6?.copyWith(color: authHintTextColor),
                                        border: InputBorder.none,
                                        hintText: "Your School Email"),
                                    onChanged: (value) {
                                      if (mounted) {
                                        setState(() {
                                          email = value.trim();
                                        });
                                      }
                                    },
                                  ),
                                  Divider(height: 0, thickness: 2 * hp, color: authHintTextColor),
                                  myCheckBoxFormField(textTheme)
                                ],
                              )),
                        ),
                        SizedBox(height: 110 * hp)
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: AuthBar(
                        buttonText: "Register",
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (mounted) {
                              setState(() => loading = true);
                            }
                            String localEmail = email.toLowerCase();
                            dynamic result = await _auth.createEmailUser(localEmail);
                            if (result is User?) {
                              final int tempIndex = localEmail.lastIndexOf('@');
                              final String domain = localEmail.substring(tempIndex);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => pixelProvider(context,
                                      child: WaitVerification(domain: domain, domainEmail: localEmail))));
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
                        }),
                  ),
                ],
              ),
            ),
          );
  }
}
