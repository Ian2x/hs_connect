import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/reports/reportForm.dart';
import 'package:provider/provider.dart';

import '../pixels.dart';
import '../widgets/loading.dart';

class ReportSheet extends StatefulWidget {

  final ReportType reportType;
  final DocumentReference entityRef; // ref to message, post, comment, or reply

  const ReportSheet({Key? key,
    required this.reportType,
    required this.entityRef,
  }) : super(key: key);


  @override
  _ReportSheetState createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> with TickerProviderStateMixin {
  static const double iconSize = 20;
  static const double fontSize = 16;
  late AnimationController controller;
  bool disposeController = true;

  @override
  void initState() {
    controller = BottomSheet.createAnimationController(this);
    controller.duration = Duration(milliseconds: 250);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    double sheetHeight= MediaQuery.of(context).size.height * 0.15;


    final userData = Provider.of<UserData?>(context);
    if (userData==null) return Loading();

    return Container(
      constraints: BoxConstraints(
        maxHeight: sheetHeight,
      ),
      padding: EdgeInsets.fromLTRB(13*wp, 0, 0, 0),
      child: Column(
        children: [
          TextButton(
              onPressed: (){},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed:(){
                      showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          transitionAnimationController: controller,
                          isScrollControlled: true,
                          builder: (context) => new ReportForm(reportType: widget.reportType, entityRef: widget.entityRef));
                    },
                    child:
                    Row(
                      children: [
                        Icon(Icons.flag, color: ThemeColor.black, size: iconSize*hp),
                        SizedBox(width:20*wp),
                        Text("Report", style: ThemeText.groupBold(color: ThemeColor.black, fontSize: fontSize*hp),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: ThemeColor.backgroundGrey, thickness: 2*hp, height: 0),
                  Container(
                    //color: Colors.orange,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child:
                        Row(
                        children: [
                          Icon(Icons.close_rounded, size: iconSize*hp, color: ThemeColor.mediumGrey),
                          SizedBox(width:20*wp),
                          Text("Cancel", style: ThemeText.groupBold(color: ThemeColor.mediumGrey, fontSize: fontSize*hp),
                          ),
                        ],
                      )
                    ),
                  ),
                ],
              )
          )
        ],
      ),
    );
  }
}

