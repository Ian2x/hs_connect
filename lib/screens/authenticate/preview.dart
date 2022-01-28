import 'package:flutter/material.dart';
import 'package:hs_connect/screens/authenticate/signIn.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/widgets/gradientText.dart';


class PreviewPage extends StatelessWidget {

  final Function toggleView;


  const PreviewPage({Key? key,
    required this.toggleView,
  }) : super(key: key);

  @override


  Widget build(BuildContext context) {

    double height =MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: Gradients.blueRed(),
        ),
        child: Column(
          children: [
            SizedBox(height: height*.23),
            SizedBox(
              height: height/6,
              child:
              Image.asset('assets/logo1background.png'),
            ),
            SizedBox(height:height*.02),
            Text(
              "Join the Circle",
              style: ThemeText.inter(fontWeight: FontWeight.w800,
                  fontSize: 30, color: Colors.white),
            ),
            SizedBox(height:height*.02),
            Text(
              "Talk with your classmates,",
              style: ThemeText.inter(fontWeight: FontWeight.normal,
                  fontSize: 18, color: Colors.white),
            ),
            SizedBox(height:height*.005),
            Text(
                  " anonymously.",
              style: ThemeText.inter(fontWeight: FontWeight.normal,
                  fontSize: 17, color: Colors.white),
            ),
            SizedBox(height: height*.13),
            ActionChip(
              padding: EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0),
              backgroundColor: Colors.white,
              label: GradientText(
                'Sign up',
                style: ThemeText.inter(fontWeight: FontWeight.w700, fontSize: 21, //TODO: Convertto HP
                ),
                gradient: Gradients.blueRed(),
              ),
              onPressed: (){
                toggleView();
              },
            ),
            SizedBox(height:height*.02),
            TextButton(
              child:Text(
                "Login",
                style: ThemeText.inter(fontWeight: FontWeight.w700,
                    fontSize: 21, color: Colors.white),
              ),
              //TODO: Convertto HP
              onPressed: (){
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => pixelProvider(context, child: SignIn(toggleView: toggleView))));
              },
            ),
            SizedBox(height:height*.1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
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
                  //TODO: Convertto HP
                  onPressed: (){
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => SignIn(toggleView: toggleView)));
                  },
                ),
              ],
            )


          ],
        )
      ),
    );
  }
}
