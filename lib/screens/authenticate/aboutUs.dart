import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';
import 'package:provider/provider.dart';

import 'authenticate.dart';



class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    double fontSize = 21 *hp;
    double fontHeight = 1.4;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: Gradients.blueRed(),
        ),
        child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 68*hp),
              Row(
                children: [
                  SizedBox(width: 10*wp),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child:Text(
                        "Back",
                        style: ThemeText.inter(fontWeight: FontWeight.normal,
                            fontSize: 16*hp, color: Colors.white),
                      )
                  ),
                ],
              ),
              SizedBox(height: 60*hp),
              SizedBox(
                height: 90*hp,
                child:
                Image.asset('assets/sublogo1cropped.png'),
              ),
              SizedBox(height: 20*hp),
              Text(
                "About Circles",
                style: ThemeText.inter(fontWeight: FontWeight.w800,
                    fontSize: 30*hp, color: Colors.white),
              ),
              SizedBox(height: 15*hp),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 60*wp),
                child: Column(
                  children: [
                    SizedBox(height:40*hp),
                    Text(
                        "Circle is an app that lets highschoolers chat anonymously. ",
                    style: ThemeText.inter(fontWeight: FontWeight.normal,
                      fontSize: fontSize, color: Colors.white, height: fontHeight),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height:20*hp),
                    Text(
                      "Talk with people from just your high school, or other high schools on the app.",
                      style: ThemeText.inter(fontWeight: FontWeight.normal,
                          fontSize: fontSize, color: Colors.white, height:fontHeight),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height:20*hp),
                    Text(
                      "Post about classes, sports, events, etc.",
                      style: ThemeText.inter(fontWeight: FontWeight.normal,
                          fontSize: fontSize, color: Colors.white, height:fontHeight),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height:60*hp),
                   /* ActionChip(
                      padding: EdgeInsets.fromLTRB(60*wp, 15*hp, 60*wp, 15*hp),
                      backgroundColor: Colors.white,
                      label: GradientText(
                        'Sign up',
                        style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 23*hp,
                        ),
                        gradient: Gradients.blueRed(),
                      ),
                      onPressed: (){
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) => pixelProvider(context, child: Authenticate(signIn: false))));
                      },
                    ),*/

                  ],
                )
              )


            ],
          )
      ),




    );
  }
}
