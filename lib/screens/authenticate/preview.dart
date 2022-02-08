import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

import 'aboutUs.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: Gradients.blueRedFull(),
          ),
          child: Column(
            children: [
              SizedBox(height: 160 * hp),
              SizedBox(
                height: 115 * hp,
                child: Image.asset('assets/sublogo1cropped.png'),
              ),
              SizedBox(height: 15 * hp),
              Text("circles.co",
                  style: textTheme.headline4?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 20 * hp),
              Text(
                "Talk with your classmates,",
                style: textTheme.subtitle1?.copyWith(color: Colors.white),
              ),
              SizedBox(height: 4 * hp),
              Text(
                "anonymously.",
                style: textTheme.subtitle1?.copyWith(color: Colors.white),
              ),
              SizedBox(height: 70 * hp),
              ActionChip(
                padding: EdgeInsets.fromLTRB(35 * wp, 15 * hp, 35 * wp, 15 * hp),
                backgroundColor: Colors.white,
                label: Text(
                  'Sign up',
                  style: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => pixelProvider(context, child: Authenticate(signIn: false))));
                },
              ),
              SizedBox(height: 15 * hp),
              TextButton(
                child: Text(
                  "Login",
                  style: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => pixelProvider(context, child: Authenticate(signIn: true))));
                },
              ),
              SizedBox(height: 105 * hp),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => pixelProvider(context, child: AboutUs())));
                      },
                      child: Text(
                        "About",
                        style: textTheme.subtitle1?.copyWith(color: Colors.white)
                      ))
                ],
              )
            ],
          )),
    );
  }
}
