import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';
import '../../shared/myStorageManager.dart';
import '../../shared/pageRoutes.dart';
import '../../shared/widgets/loading.dart';
import '../../shared/widgets/myBackButtonIcon.dart';
import '../wrapper.dart';
import 'authButton.dart';

class SMSCode extends StatefulWidget {
  final String phoneNumber;
  final String domain;
  final bool signUp;
  const SMSCode({Key? key, required this.phoneNumber, required this.domain, required this.signUp}) : super(key: key);

  @override
  _SMSCodeState createState() => _SMSCodeState();
}

class _SMSCodeState extends State<SMSCode> {

  String? error;
  String? smsCode;
  String? prepSMSCode;
  bool isLoading = true;
  bool sendingSMS = true;
  final AuthService _auth = AuthService();
  final auth = FirebaseAuth.instance;
  String verificationCode = '';


  @override
  void initState() {
    signUp();
    super.initState();
  }

  Future<void> onVerificationCompleted (PhoneAuthCredential credential) async {
    await auth.signInWithCredential(credential).then((result) async {
      if (result.user!=null) {
        if (widget.signUp) {
          await _auth.registerPhoneUserData(result.user!, widget.domain);
          await MyStorageManager.saveData('showSignUp', true);
        }
        Navigator.of(context).pushAndRemoveUntil(
            NoAnimationMaterialPageRoute(builder: (context) => Wrapper()), (Route<dynamic> route) => false);
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
            error = "An unexpected error occurred.";
          });
        }
      }
    });
  }

  Future<void> signUp() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: Duration(seconds: 30),
      verificationCompleted: onVerificationCompleted,
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          if (e.code == 'invalid-phone-number') {
            setState(() => error = "The provided phone number is not valid.");
          } else {
            setState(() => error = e.message ?? e.code);
          }
          setState(() {
            isLoading = false;
            sendingSMS = false;
          });
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        if (mounted) {
          setState(() {
            isLoading = false;
            sendingSMS = false;
            verificationCode = verificationId;
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) {
          setState(() {
            isLoading = false;
            sendingSMS = false;
            verificationCode = verificationId;
          });
        }
      },
    );
  }


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
        // title: sendingSMS ? Text("Sending verification code...", style: textTheme.headline6?.copyWith(color: Colors.black)) : null,
        backgroundColor: Colors.white,
      ),
      body: isLoading ? Loading(spinColor: Colors.black, backgroundColor: Colors.white,) : Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Verification Code:',
                    style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 30, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    width: 185,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: TextField(
                      autocorrect: false,
                      style: TextStyle(fontFamily: "Inter", fontSize: 35, color: authPrimaryTextColor, fontFeatures: [
                        FontFeature.tabularFigures()
                      ]),
                      maxLines: null,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                      ],
                      keyboardType: TextInputType.number,
                      //textAlign: TextAlign.center,
                      autofocus: true,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(fontFamily: "Inter", fontSize: 35, color: authHintTextColor, fontFeatures: [
                            FontFeature.tabularFigures()
                          ]),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: authHintTextColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: authHintTextColor),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(20, 7, 0, 7),
                          hintText: "000000"),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            prepSMSCode = value;
                          });
                        }
                      },
                    )
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.center,
                  child: Text(
                    error ?? "We've sent a verification code.",
                    style: textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 17, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 150),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width * 0.5 - 180,
            width: 360,
            child: AuthButton(
                buttonText: "Next",
                hasText: prepSMSCode?.length==6,
                onPressed: () async {
                  dismissKeyboard(context);
                  if (mounted) {
                    setState(() {
                      isLoading = true;
                      smsCode = prepSMSCode;
                    });
                  }
                  try {
                    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationCode, smsCode: smsCode!);
                    await onVerificationCompleted(credential);
                  } catch (e) {
                    if (mounted) {
                      setState(() => isLoading = false);
                  }
                  }
                }),
          ),
        ],
      ),
    );
  }
}
