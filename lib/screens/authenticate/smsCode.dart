import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';
import '../../shared/myStorageManager.dart';
import '../../shared/widgets/loading.dart';
import '../../shared/widgets/myBackButtonIcon.dart';
import '../wrapper.dart';
import 'authButton.dart';

class SMSCode extends StatefulWidget {
  final String phoneNumber;
  final String domain;
  const SMSCode({Key? key, required this.phoneNumber, required this.domain}) : super(key: key);

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
        await _auth.registerPhoneUserData(result.user!, widget.domain);
        await MyStorageManager.saveData('showSignUp', true);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Wrapper()), (Route<dynamic> route) => false);
      } else {
        if (mounted) {
          setState(() {
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
      timeout: const Duration(seconds: 60),
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
        title: sendingSMS ? Text("Sending verification code...", style: textTheme.headline6?.copyWith(color: Colors.black)) : null,
        backgroundColor: Colors.white,
      ),
      body: isLoading ? Loading(spinColor: Colors.black, backgroundColor: Colors.white,) : Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Verification Code:',
                    style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextField(
                      autocorrect: false,
                      style: textTheme.headline6?.copyWith(color: authPrimaryTextColor, fontSize: 30),
                      maxLines: null,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintStyle: textTheme.headline6?.copyWith(color: authHintTextColor, fontSize: 30),
                          border: InputBorder.none,
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
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.center,
                  child: Text(
                    error ?? "We've sent a verification code.",
                    style: textTheme.subtitle1?.copyWith(color: Colors.black, fontSize: 14, height: 1.3),
                    textAlign: TextAlign.center,
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
