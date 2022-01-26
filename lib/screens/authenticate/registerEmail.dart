import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/screens/authenticate/waitVerification.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
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
  String email='';
  String? error;


  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return loading
        ? Scaffold(backgroundColor: colorScheme.background, body: Loading())
        : Scaffold(
      backgroundColor: colorScheme.surface,
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
                  print(result);
                  if (result is User?) {
                    final int tempIndex = email.lastIndexOf('@');
                    final String domain = email.substring(tempIndex);
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => pixelProvider(context, child: WaitVerification(domain: domain))));
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
            padding: EdgeInsets.symmetric(vertical: 20*hp, horizontal: 50*wp),
            child: Form(
              key: _formKey,
              child:
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 78*hp),
                    Center(
                        child:
                        Column(
                          children: [
                            Container(
                              height: 62*hp,
                              width: 62*hp,
                              decoration: new BoxDecoration(
                                color: colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: 70*hp),
                            Text("Make your Account", style: Theme.of(context).textTheme.headline5),
                            SizedBox(height:15*hp),
                            Text('Register with your school email.',
                                style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.secondary)),
                            SizedBox(height: 39*hp),
                          ],
                        )
                    ),
                    SizedBox(height: error!=null ? 10*hp : 78*hp),
                    error!=null ? Text(error!, style: Theme.of(context).textTheme.subtitle2) : Container(),
                    TextField(
                      autocorrect:false,
                      style: Theme.of(context).textTheme.headline6?.copyWith(color: colorScheme.primary),
                      maxLines: null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.headline6?.copyWith(color: colorScheme.onError),
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
                    Divider(height:20*hp, thickness: 2*hp, color: colorScheme.onError),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
