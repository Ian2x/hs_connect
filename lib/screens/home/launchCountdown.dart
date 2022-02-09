import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/myOutlinedButton.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class LaunchCountdown extends StatefulWidget {
  final UserData userData;
  const LaunchCountdown({Key? key, required this.userData}) : super(key: key);

  @override
  _LaunchCountdownState createState() => _LaunchCountdownState();
}

class _LaunchCountdownState extends State<LaunchCountdown> {
  String? shareURL;

  @override
  void initState() {
    getShareURL();
    super.initState();
  }
  
  void getShareURL() async {
    final temp = await FirebaseFirestore.instance.collection('appStoreLink').doc('appStoreLink').get();
    if (mounted) {
      setState(() => shareURL = temp.get('appStoreLink'));
    }
  }


  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final textTheme = Theme.of(context).textTheme;

    String groupName = widget.userData.fullDomainName!=null ? widget.userData.fullDomainName! : widget.userData.domain;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 25*hp),
          child: Container(
              decoration: BoxDecoration(
              gradient: Gradients.blueRedFull(begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(30*hp),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27.5*hp),
                color: Colors.white,
              ),
              margin: EdgeInsets.all(2.5*hp),
              child: Container(height: 540*hp, width: 320*hp, padding: EdgeInsets.symmetric(horizontal: 20*wp), child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 80*hp,
                        width: 80*hp,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/splash1cropped.png')
                          )
                        )
                      ),
                      SizedBox(height: 25*hp),
                      Text("Welcome, you're early.", style: textTheme.headline6?.copyWith(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      SizedBox(height: 20*hp),
                      Text("circles.co will launch at " + groupName + " on:", style: textTheme.headline6?.copyWith(color: Colors.black), textAlign: TextAlign.center),
                      SizedBox(height: 50*hp),
                      Text(DateFormat('EEEEEEEEE, MMMM d').format(widget.userData.launchDate!.toDate()), style: textTheme.headline6?.copyWith(color: Colors.black), textAlign: TextAlign.center),
                      SizedBox(height: 50*hp),
                      Text("Tell your friends to sign up!", style: textTheme.headline6?.copyWith(color: Colors.black), textAlign: TextAlign.center),
                      SizedBox(height: 25*hp),
                      MyOutlinedButton(
                          borderRadius: 30*hp,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.fromLTRB(35*wp,10*hp,35*wp,10*hp),
                          gradient: Gradients.blueRedFull(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          onPressed: () {
                            if (shareURL!=null) {
                              Share.share(shareURL!);
                            }
                          },
                          child: Text('Share', style: textTheme.headline6?.copyWith(color: Colors.black)))
                    ]
                  )
              )
            )
          ),
        )
    );
  }
}
