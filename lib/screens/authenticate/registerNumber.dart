import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/smsCode.dart';
import 'package:hs_connect/shared/pageRoutes.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';
import '../../shared/widgets/loading.dart';
import '../../shared/widgets/myBackButtonIcon.dart';
import 'authButton.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterNumber extends StatefulWidget {
  final String domain;

  const RegisterNumber({Key? key, required this.domain}) : super(key: key);

  @override
  _RegisterNumberState createState() => _RegisterNumberState();
}

class _RegisterNumberState extends State<RegisterNumber> {
  // text field state
  String? error;
  bool isLoading = false;
  bool numberValidated = false;

  final AuthService _auth = AuthService();

  PhoneNumber initial = PhoneNumber(isoCode: "US");
  String? phoneNumber;

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
      body: isLoading
          ? Loading(spinColor: Colors.black, backgroundColor: Colors.white)
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Your phone number is...',
                          style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: InternationalPhoneNumberInput(
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
                          inputDecoration: InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: authHintTextColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2, color: authHintTextColor))),
                          textStyle: textTheme.headline5?.copyWith(fontSize: 28, color: authPrimaryTextColor, letterSpacing: 2.5),
                          selectorTextStyle: textTheme.headline5?.copyWith(fontSize: 28, color: authPrimaryTextColor, letterSpacing: 2.5),
                          formatInput: false,
                          initialValue: initial,
                          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        alignment: Alignment.center,
                        child: Text(
                          error ?? "We'll send a verification text. Standard rates apply.",
                          style: textTheme.subtitle1?.copyWith(color: authPrimaryTextColor, fontSize: 14, height: 1.3),
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
                      hasText: numberValidated,
                      onPressed: () async {
                        if (phoneNumber != null) {
                          if (!numberValidated) {
                            if (mounted) {
                              setState(() => error = "Please enter a valid number.");
                            }
                          } else {
                            if (mounted) {
                              setState(() {
                                isLoading = true;
                                numberValidated = false;
                              });
                            }
                            bool inUse = await _auth.checkIfNumberInUse(phoneNumber!);
                            if (!inUse) {
                              // push smsCode page
                              await Navigator.of(context).push(NoAnimationMaterialPageRoute(
                                  builder: (context) =>
                                      SMSCode(phoneNumber: phoneNumber!, domain: widget.domain, signUp: true)));
                            } else {
                              if (mounted) {
                                setState(() => error = "This number is already in use.");
                              }
                            }
                            if (mounted) {
                              setState(() => isLoading = false);
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
