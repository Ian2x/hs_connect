import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/widgets/myOutlinedButton.dart';
import 'package:intl/intl.dart';
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
    final textTheme = Theme.of(context).textTheme;

    String groupName =
        widget.userData.fullDomainName != null ? widget.userData.fullDomainName! : widget.userData.domain;
    Color groupColor = widget.userData.domainColor ?? Colors.blue;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 25),
          child: Container(
              child: Container(
                  height: 540,
                  width: 320,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(height: 110),
                    Text("Welcome, you're early.",
                        style: textTheme.headline4?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    SizedBox(height: 30),
                    Text("Convo will launch at " + groupName + " on:",
                        style: textTheme.headline6?.copyWith(color: Colors.black), textAlign: TextAlign.center),
                    SizedBox(height: 10),
                    Text(DateFormat('EEEEEEEEE, MMMM d').format(widget.userData.launchDate!.toDate()),
                        style: textTheme.headline6?.copyWith(color: Colors.black.withOpacity(0.65)), textAlign: TextAlign.center),
                    SizedBox(height: 130),
                    GestureDetector(
                      onTap: () {
                        if (shareURL != null) {
                          Share.share(shareURL!);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(95, 10, 95, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: groupColor, width: 1.5)
                        ),
                        child: Text('Share', style: textTheme.headline6?.copyWith(color: groupColor))
                      )
                    ),
                  ]))),
        ));
  }
}
