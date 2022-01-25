import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/registerUser.dart';
import 'dart:async';

import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class WaitVerification extends StatefulWidget {
  const WaitVerification({Key? key, required this.domain}) : super(key: key);

  final String domain;

  @override
  _WaitVerificationState createState() => _WaitVerificationState();
}

class _WaitVerificationState extends State<WaitVerification> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;

  @override
  void initState() {
    user = auth.currentUser;
    user!.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              height: 625*hp,
              width: 314*hp,
              decoration: new BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 703*hp),
            Text("Make your Account", style: Theme.of(context).textTheme.headline5),
            SizedBox(height:15*hp),
            Text('Register with your school email.',
                style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.secondary)),
            SizedBox(height: 39*hp),
          ],
        ),
      ),
    );
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user!.reload();
    if (user!.emailVerified) {
      timer!.cancel();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => pixelProvider(context, child: RegisterUser(domain: widget.domain))));
    }
  }
}
