import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hs_connect/screens/authenticate/registerNumber.dart';
import 'package:hs_connect/services/domains_data_database.dart';

import '../../shared/constants.dart';
import '../../shared/widgets/myBackButtonIcon.dart';
import 'authButton.dart';

class ChooseSchool extends StatefulWidget {
  const ChooseSchool({Key? key}) : super(key: key);

  @override
  _ChooseSchoolState createState() => _ChooseSchoolState();
}

class _ChooseSchoolState extends State<ChooseSchool> {
  String? selectedDomain;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: myBackButtonIcon(
            context,
            overrideColor: Colors.black,
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Stack(children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Your school is...",
                    style: ThemeText.quicksand(fontWeight: FontWeight.w700, fontSize: 30, color: Colors.black),
                  ),
                ),
                FutureBuilder(
                  future: DomainsDataDatabaseService().getAllDomains(),
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      List<String> domainOptions = snapshot.data;
                      domainOptions.sort();
                      return Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: DropdownSearch<String>(
                          mode: Mode.MENU,
                          items: domainOptions,
                          onChanged: (String? s) {
                            if (mounted) {
                              setState(() => selectedDomain = s);
                            }
                          },
                          popupBackgroundColor: Colors.white,
                          dropdownSearchDecoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          popupItemBuilder: (context, s, bool) {
                            return Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Text(s, style: textTheme.headline5?.copyWith(color: Colors.black87)));
                          },
                          dropdownBuilder: (context, selectedItem) {
                            return Text(selectedItem ?? "@school.edu",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.headline4
                                    ?.copyWith(color: selectedItem == null ? authHintTextColor : Colors.black));
                          },
                        ),
                      );
                    } else {
                      return Container(
                          padding: EdgeInsets.all(21), child: SpinKitThreeBounce(size: 30.0, color: Colors.black));
                    }
                  },
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final textTheme = Theme.of(context).textTheme;
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                            contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                            backgroundColor: Colors.white,
                            titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                            title: Text(
                              "Sorry :(",
                              textAlign: TextAlign.center,
                              style: textTheme.headline6?.copyWith(fontSize: 22, color: Colors.black),
                            ),
                            content: Container(
                              height: 130,
                              alignment: Alignment.topCenter,
                              child: Text(
                                "So far, we've only expanded to these schools. If you'd like to see Convo at your school, please contact us at:\nteam@getconvo.app",
                                style: textTheme.headline4?.copyWith(fontSize: 18, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      "Don't see your school?",
                      style: textTheme.subtitle1?.copyWith(
                          color: authPrimaryTextColor, fontSize: 15, height: 1.3, decoration: TextDecoration.underline),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                SizedBox(height: 150)
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width * 0.5 - 180,
            width: 360,
            child: AuthButton(
                buttonText: "Next",
                hasText: selectedDomain != null,
                onPressed: () async {
                  if (selectedDomain != null) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => RegisterNumber(domain: selectedDomain!)));
                  }
                }),
          )
        ]));
  }
}
