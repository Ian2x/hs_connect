import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

import 'authBar.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  const SignIn({Key? key, required this.toggleView}) : super(key: key);


  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String username = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return loading
        ? Scaffold(
        backgroundColor: colorScheme.background,
        body: Loading()
    )
        : Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 110*hp,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          gradient: Gradients.blueRed(begin: Alignment.topLeft , end: Alignment.bottomRight),
                        ),
                        child: SizedBox(),
                      ),
                      SizedBox(height: 10*hp),
                      Row(
                        children: [
                          SizedBox(width: 10*hp),
                          TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child:Text(
                                "Cancel",
                                style: ThemeText.inter(fontWeight: FontWeight.normal,
                                    fontSize: 16*hp, color: Colors.grey),
                              )
                          ),
                        ],
                      ),
                      SizedBox(height: 15*hp),
                      Center(
                          child:
                          Column(
                            children: [
                              SizedBox(
                                height: 80 *hp,
                                child:
                                Image.asset('assets/logo1background.png'),
                              ),
                              SizedBox(height: 20*hp),
                              Text(
                                'Login',
                                style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 28*hp, color: Colors.black
                                ),
                              ),
                              SizedBox(height: 30*hp),
                              Container(
                                padding:EdgeInsets.fromLTRB(20*wp,0,20*wp,0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                          autocorrect:false,
                                          style: Theme.of(context).textTheme.headline6,
                                          maxLines: null,
                                          decoration: InputDecoration(
                                              hintStyle: Theme.of(context).textTheme.headline6?.copyWith(color: colorScheme.onError),
                                              border: InputBorder.none,
                                              hintText: "Username"),
                                          validator: (val) {
                                            if (val == null) return 'Error: null value';
                                            if (val.isEmpty)
                                              return 'Enter username';
                                            else
                                              return null;
                                          },
                                          onChanged: (val) {
                                            if (mounted) {
                                              setState(() => username = val);
                                            }
                                          }
                                      ),
                                      Divider(height:15*hp, thickness: 2*hp, color: colorScheme.onError),
                                      TextFormField(
                                          autocorrect:false,
                                          style: Theme.of(context).textTheme.headline6,
                                          decoration: InputDecoration(
                                              hintStyle: Theme.of(context).textTheme.headline6?.copyWith(color: colorScheme.onError),
                                              border: InputBorder.none,
                                              hintText: "Password"),
                                          obscureText: true,
                                          validator: (val) {
                                            if (val == null) return 'Error: null value';
                                            if (val.length < 1)
                                              return 'Password is empty';
                                            else
                                              return null;
                                          },
                                          onChanged: (val) {
                                            if (mounted) {
                                              setState(() => password = val);
                                            }
                                          }),
                                      Divider(height:15*hp, thickness: 2*hp, color: colorScheme.onError),
                                      error != '' ? Text(
                                        'Login', style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 28*hp, color: Colors.black))
                                              : Container(),
                                    ],
                                  ),
                                ),
                              ),

                                SizedBox(height: 20*hp),
                                SizedBox(height:15*hp),
                                SizedBox(height: 50*hp),
                              ],
                            )
                        ),
                      ]),
                ),
              Positioned(
                bottom:0,
                right:0,
                left:0,
                child: AuthBar(buttonText: "Sign in",
                  onPressed: () async {
                    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                      if (mounted) {
                        setState(() => loading = true);
                      }
                      dynamic result = await _auth.signInWithUsernameAndPassword(username, password);
                      print(result);
                      if (!(result is User?)) {
                        if (mounted) {
                          setState(() {
                            error = 'Could not sign in with those credentials';
                            loading = false;
                          });
                        }
                      } else {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => pixelProvider(context, child: Wrapper())), (Route<dynamic> route) => false);
                      }
                    }
                  },
                ),
              ),
            ]
    )
    );
  }
}
