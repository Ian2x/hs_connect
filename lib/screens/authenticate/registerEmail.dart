import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs_connect/screens/authenticate/preview.dart';
import 'package:hs_connect/screens/authenticate/waitVerification.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/gradientText.dart';
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
                          Navigator.pushReplacement(
                            context,
                            NoAnimationMaterialPageRoute(
                                builder: (context) => pixelProvider(context, child: previewPage())),
                          );
                        },
                        child:Text(
                          "Cancel",
                          style: ThemeText.inter(fontWeight: FontWeight.normal,
                              fontSize: 16*hp, color: Colors.grey),
                        )
                    ),
                  ],
                ),
                SizedBox(height: 20*hp),
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
                          'Sign Up',
                          style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 28*hp, color: Colors.black //TODO: Convertto HP
                          ),
                        ),
                        SizedBox(height: 20*hp),
                        Center(
                          child:
                          error != null ? Center(
                            child: Text(
                                error!, style: ThemeText.inter(fontWeight: FontWeight.w500, fontSize: 13*hp, color: Colors.black)),
                          ) :
                          Text("Verify your school with your email.",
                              style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.onSurface, fontSize: 14)),
                        ),
                        SizedBox(height: 50*hp),
                      ],
                    )
                ),
                Form(
                  key: _formKey,
                  child:
                  Container(
                      padding:EdgeInsets.fromLTRB(20.0,0,20,0),
                      child:
                        Column(
                          children: [
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
                          ],
                        )
                  ),
                ),
                SizedBox(height:90*hp) ],
            ),
          ),
          Positioned(
            bottom:0,
            left:0,
            child: AuthBar(buttonText: "Register",
                onPressed: () async {
              print(error);
                  if (mounted) {
                    setState(() => loading = true);
                  }
                  dynamic result = await _auth.createEmailUser(email);
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
                        /*errorMsg +=
                            'If you think this is a mistake, please contact us at ___ for support. [Error Code: ' +
                                result.code +
                                ']';*/
                        error = errorMsg;
                        loading = false;
                      });
                    }
                  } else {
                    if (mounted) {
                      setState(() {
                        error =  result.toString();
                        loading = false;
                      });
                    }
                  }
                }),
          ),
        ],
      ),
    );
  }
}
