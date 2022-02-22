import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/registerEmail.dart';
import 'package:hs_connect/screens/authenticate/signIn.dart';
import 'package:hs_connect/shared/constants.dart';
import 'aboutUs.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

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
              SizedBox(height: 180),
              SizedBox(
                height: 95,
                child: Image.asset('assets/sublogo2.png'),
              ),
              SizedBox(height: 60),
              Text("convo",
                  style: textTheme.headline4?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
              SizedBox(height: 15),
              Text(
                "Talk with your classmates,",
                style: textTheme.subtitle1?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 19),
              ),
              SizedBox(height: 4),
              Text(
                "anonymously.",
                style: textTheme.subtitle1?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 19),
              ),
              SizedBox(height: 100),
              ActionChip(
                padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                backgroundColor: Colors.white,
                label: Text(
                  'Sign up',
                  style: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RegisterEmail()));
                },
              ),
              SizedBox(height: 15),
              TextButton(
                child: Text(
                  "Login",
                  style: textTheme.headline6?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SignIn()));
                },
              ),
              SizedBox(height: 65),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => AboutUs()));
                      },
                      child: Text(
                        "About",
                        style: textTheme.subtitle1?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 19)
                      ))
                ],
              )
            ],
          )),
    );
  }
}
