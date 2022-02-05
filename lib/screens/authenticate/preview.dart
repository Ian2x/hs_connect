import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';
import 'package:provider/provider.dart';

import 'aboutUs.dart';


class PreviewPage extends StatelessWidget {

  const PreviewPage({Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    return Scaffold(
      body: Container(
        height: height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: Gradients.blueRed(),
        ),
        child: Column(
          children: [
            SizedBox(height: 180*hp),
            SizedBox(
              height: 130*hp,
              child:
              Image.asset('assets/sublogo1cropped.png'),
            ),
            SizedBox(height: 16*hp),
            Text(
              "Join the Circle",
              style: ThemeText.inter(fontWeight: FontWeight.w800,
                  fontSize: 30*hp, color: Colors.white),
            ),
            SizedBox(height: 16*hp),
            Text(
              "Talk with your classmates,",
              style: ThemeText.inter(fontWeight: FontWeight.normal,
                  fontSize: 18*hp, color: Colors.white),
            ),
            SizedBox(height: 4*hp),
            Text(
                  "anonymously.",
              style: ThemeText.inter(fontWeight: FontWeight.normal,
                  fontSize: 17*hp, color: Colors.white),
            ),
            SizedBox(height: 102*hp),
            ActionChip(
              padding: EdgeInsets.fromLTRB(50*wp, 15*hp, 50*wp, 15*hp),
              backgroundColor: Colors.white,
              label: GradientText(
                'Sign up',
                style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 21*hp,
                ),
                gradient: Gradients.blueRed(),
              ),
              onPressed: (){
                Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => pixelProvider(context, child: Authenticate(signIn: false))));
              },
            ),
            SizedBox(height: 16*hp),
            TextButton(
              child:Text(
                "Login",
                style: ThemeText.inter(fontWeight: FontWeight.w700,
                    fontSize: 21*hp, color: Colors.white),
              ),
              onPressed: (){
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => pixelProvider(context, child: Authenticate(signIn: true))));
              },
            ),
            SizedBox(height: 65*hp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*Text(
                  "Learn more about Circle ",
                  style: ThemeText.inter(fontWeight: FontWeight.w500,
                      fontSize: 13, color: Colors.white),
                ),
                TextButton(
                  child:Text(
                    "here",
                    style: ThemeText.inter(fontWeight: FontWeight.w500,
                        decoration1: TextDecoration.underline,
                        fontSize: 13, color: Colors.white),
                  ),
                  onPressed: (){

                  },
                ),*/
                TextButton(
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => pixelProvider(context, child: AboutUs(
                            )))  );
                  },
                  child: Text(
                    "About Circles",
                    style: ThemeText.inter(fontWeight: FontWeight.w500,
                        fontSize: 16, color: Colors.white),
                  )

                )
              ],
            )
          ],
        )
      ),
    );
  }
}
