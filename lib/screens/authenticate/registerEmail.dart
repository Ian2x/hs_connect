import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/screens/authenticate/waitVerification.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/loading.dart';

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
  String email='';
  String error="";


  @override
  Widget build(BuildContext context) {

    double unit = MediaQuery.of(context).size.height/10;

    return loading
        ? Scaffold(backgroundColor: ThemeColor.backgroundGrey, body: Loading())
        : Scaffold(
      backgroundColor: ThemeColor.white,
      body: Stack(
        children: [
          Positioned(
            bottom:0,
            left:0,
            child: AuthBar(buttonText: "Register",
                onPressed: () async {
                  if (mounted) {
                    setState(() => loading = true);
                  }
                  dynamic result = await _auth.createEmailUser(email);

                  if (result is User?) {
                    final int tempIndex = email.lastIndexOf('@');
                    final String domain = email.substring(tempIndex);
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) => WaitVerification(domain: domain)));
                  } else if (result is FirebaseAuthException) {
                    if (mounted) {
                      setState(() {
                        String errorMsg = '';
                        if (result.message != null) errorMsg += result.message!;
                        errorMsg +=
                            'If you think this is a mistake, please contact us at ___ for support. [Error Code: ' +
                                result.code +
                                ']';
                        error = errorMsg;
                        loading = false;
                      });
                    }
                  } else {
                    if (mounted) {
                      setState(() {
                        error = 'ERROR: [' + result.toString() + ']. Please contact us at ___ for support.';
                        loading = false;
                      });
                    }
                  }
                }),
            ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child:
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: unit),
                    Center(
                        child:
                        Column(
                          children: [
                            Container(
                              height: unit*.8,
                              width: unit * .8,
                              decoration: new BoxDecoration(
                                color: ThemeColor.secondaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: unit*.9),
                            Text("Make your Account", style: ThemeText.inter(fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: ThemeColor.black,
                            )),
                            SizedBox(height:15),
                            Text('Register with your school email.',
                                style: ThemeText.regularSmall(fontSize: 16, color: ThemeColor.secondaryBlue)),
                            SizedBox(height: unit/2),
                          ],
                        )
                    ),
                    SizedBox(height: unit),
                    TextField(
                      autocorrect:false,
                      style: TextStyle(
                        color: ThemeColor.mediumGrey,
                        fontSize: 18,
                        //fontWeight: ,
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                            hintStyle: TextStyle(
                              color: ThemeColor.mediumGrey,
                              fontSize: 18,
                              //fontWeight: ,
                            ),
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
                    Divider(height:20, thickness: 2, color: ThemeColor.lightMediumGrey),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
