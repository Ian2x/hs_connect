import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/loading.dart';

enum ReportType { message, post, comment, reply }

class reportSheet extends StatelessWidget {

  final ReportType reportType;
  final DocumentReference entityRef; // ref to message, post, comment, or reply
  final DocumentReference reporterRef;

  reportSheet({Key? key,
    required this.reportType,
    required this.entityRef,
    required this.reporterRef,
    //required this.text,
    //required this.createdAt,
  }) : super(key: key);

  double iconSize=25;

  @override
  Widget build(BuildContext context) {

    double sheetHeight= MediaQuery.of(context).size.height/5;

    return Container(
      constraints: BoxConstraints(
        maxHeight: sheetHeight,
      ),
      decoration: ShapeDecoration(
        color: ThemeColor.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            ),
      ),
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 0.0),
      child: Column(
        children: [
          TextButton(
              onPressed: (){},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed:(){},
                    child:
                    Row(
                      children: [
                        Icon(Icons.flag, color: ThemeColor.black, size: iconSize), SizedBox(width:10),
                        Text("Report", style: ThemeText.groupBold(color: ThemeColor.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: ThemeColor.backgroundGrey, thickness: 2),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    child:
                      Row(
                      children: [
                        Icon(Icons.close_rounded, size: iconSize, color: ThemeColor.mediumGrey),
                        SizedBox(width:10),
                        Text("Cancel", style: ThemeText.groupBold(color: ThemeColor.mediumGrey, fontSize: 16),
                        ),
                      ],
                    )
                  ),
                ],
              )
          )
        ],
      ),
    );
  }
}

