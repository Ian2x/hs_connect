import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  static double fontSize = 18;
  static double fontHeight = 1.4;

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top+5*hp),
              Row(
                children: [
                  SizedBox(width: 10 * wp),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Back",
                        style: textTheme.subtitle1?.copyWith(color: Colors.white),
                      )),
                ],
              ),
              SizedBox(height: 40 * hp),
              SizedBox(
                height: 90 * hp,
                child: Image.asset('assets/sublogo2.png'),
              ),
              SizedBox(height: 35 * hp),
              Text(
                "About Circles",
                style: textTheme.headline4?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 0 * hp),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 30 * wp),
                  child: Column(
                    children: [
                      SizedBox(height: 40 * hp),
                      Text(
                        "Circles.co is an app made by other students that lets highschoolers chat anonymously. ",
                        style: textTheme.bodyText2?.copyWith(color: Colors.white, fontSize: fontSize, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30 * hp),
                      Text(
                        "Talk with people from just your high school, or other high schools on the app.",
                        style: textTheme.bodyText2?.copyWith(color: Colors.white, fontSize: fontSize, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30 * hp),
                      Text(
                        "Post about classes, sports, memes, upcoming events, etc.",
                        style: textTheme.bodyText2?.copyWith(color: Colors.white, fontSize: fontSize, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ))
            ],
          )),
    );
  }
}
