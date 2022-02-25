import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/screens/authenticate/waitVerification.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/themeManager.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/checkboxFormField.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';

import 'authButton.dart';

class RegisterEmail extends StatefulWidget {

  const RegisterEmail({Key? key}) : super(key: key);

  @override
  _RegisterEmailState createState() => _RegisterEmailState();
}

class _RegisterEmailState extends State<RegisterEmail> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool termsAccepted = true;

  // text field state
  String email = '';
  String? error;

  String termsError = "Must read and agree to policies/terms";


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;


    return loading
        ? Scaffold(
            backgroundColor: Colors.white, body: Loading(backgroundColor: Colors.white, spinColor: Color(0xff60676c)))
        : Scaffold(
            resizeToAvoidBottomInset : false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: myBackButtonIcon(context, overrideColor: ThemeNotifier.lightThemeOnSurface,
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
                      /*Container(
                        padding: EdgeInsets.fromLTRB(20.0,0,0,0),
                        alignment: Alignment.topLeft,
                        child: Column(
                        children: [
                        Row(
                          children: [
                            Spacer(),
                            Container(
                              padding:EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child:
                              SizedBox(
                                height: 50,
                                child: Image.asset('assets/Splash2.png'),
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                          ],
                        ),
                      ),*/
                      SizedBox(height: 60),
                      Container(
                        padding:EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Your school email is...',
                          style: ThemeText.quicksand(
                              fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Column(
                              children: [
                                TextField(
                                  autofocus: true,
                                  autocorrect: false,
                                  style: textTheme.headline6?.copyWith(color: authPrimaryTextColor,
                                    fontSize: 25),
                                  maxLines: null,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      hintStyle: textTheme.headline6?.copyWith(color: authHintTextColor, fontSize: 25),
                                      border: InputBorder.none,
                                      hintText: "convo@school.org"),
                                  onChanged: (value) {
                                    if (mounted) {
                                      setState(() {
                                        email = value.trim();
                                      });
                                    }
                                  },
                                ),
                              ],
                            )),
                      ),
                      SizedBox(height:20),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        alignment: Alignment.topLeft,
                        child: Text(
                          error != null ? error!
                              : "We'll send you an email to verify your school.",
                          style:
                          textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 14, height: 1.3),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 160)
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: MediaQuery.of(context).size.width * 0.5 - 180,
                  width: 360,
                  child: AuthButton(
                      buttonText: "Register",
                      hasText: email!="",
                      onPressed: () async {
                        if (email!= ""){
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
                                builder: (context) => WaitVerification(domain: domain, domainEmail: localEmail)));
                          } else if (result is FirebaseAuthException) {
                            if (mounted) {
                              setState(() {
                                String errorMsg = '';
                                if (result.message != null) errorMsg += result.message!;
                                error = errorMsg;
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
                        }
                      }),
                ),
              ],
            ),
          );
  }
}
