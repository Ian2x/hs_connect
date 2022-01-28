import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/wrapper.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({Key? key, required this.domain}) : super(key: key);

  final String domain;

  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
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
        body: Stack(
            children: [
              Column(
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
                            },
                            child:Text(
                              "Cancel",
                              style: ThemeText.inter(fontWeight: FontWeight.normal,
                                  fontSize: 16*hp, color: Colors.grey),
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 30*hp),
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
                              'Verify',
                              style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 28*hp, color: Colors.black //TODO: Convertto HP
                              ),
                            ),
                            /*GradientText(
                        'Sign up',
                        style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 28*hp, //TODO: Convertto HP
                        ),
                        gradient: Gradients.blueRed(),
                      ),  */                          SizedBox(height:15*hp),
                            SizedBox(height: 50*hp),
                          ],
                        )
                    ),
                  ])
            ])
    );
  }
}
