import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/registerPassword.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';

import '../../services/auth.dart';
import 'authButton.dart';

class RegisterEmail extends StatefulWidget {
  const RegisterEmail({Key? key}) : super(key: key);

  @override
  _RegisterEmailState createState() => _RegisterEmailState();
}

class _RegisterEmailState extends State<RegisterEmail> {
  // text field state
  String email = '';
  String? error;

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
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
                    'Your school email is...',
                    style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: TextField(
                      autofocus: true,
                      autocorrect: false,
                      style: textTheme.headline6?.copyWith(color: authPrimaryTextColor, fontSize: 25),
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
                    )),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.topLeft,
                  child: Text(
                    error ?? "We'll send you an email to verify your school.",
                    style: textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 14, height: 1.3),
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
                buttonText: "Next",
                hasText: email != "",
                onPressed: () async {
                  bool inUse = await _auth.checkIfEmailInUse(email); //returns true if Used
                  bool isEmail = EmailValidator.validate(email) && email != "";
                  if (!inUse && isEmail) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => RegisterPassword(email: email.toLowerCase())));
                  } else {
                    if (mounted) {
                      if (!isEmail) {
                        setState(() => error = "Enter a valid email.");
                      } else {
                        setState(() => error = "This email is taken. If you made this account, login instead.");
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
