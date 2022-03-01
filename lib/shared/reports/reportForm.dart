import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/reports_database.dart';
import 'package:provider/provider.dart';

import '../widgets/loading.dart';

class ReportForm extends StatefulWidget {
  final ReportType reportType;
  final DocumentReference entityRef;

  const ReportForm({Key? key, required this.reportType, required this.entityRef}) : super(key: key);

  @override
  _ReportFormState createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  static const String emptyTextError = 'Can\'t submit a report without a description';

  FocusNode textFocusNode = FocusNode();

  String _text = '';
  String? error;

  bool loading = false;
  bool submitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double phoneHeight = MediaQuery.of(context).size.height;
    double phoneWidth = MediaQuery.of(context).size.width;

    final userData = Provider.of<UserData?>(context);

    final colorScheme = Theme.of(context).colorScheme;

    if (loading || userData == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
          constraints: BoxConstraints.expand(),
          child: Loading(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: submitted
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Container(
                width: phoneWidth,
                constraints: BoxConstraints(),
                padding: EdgeInsets.fromLTRB(10, 7, 10, 4),
                child: Row(children: <Widget>[
                  IconButton(
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.close),
                    iconSize: 30,
                    onPressed: () {
                      int count = 0;
                      Navigator.popUntil(context, (route) {
                        return count++ == 2;
                      });
                    },
                  ),
                  Spacer(),
                  Text("Report received.", style: Theme.of(context).textTheme.headline5),
                  Spacer(),
                  SizedBox(width: 30)
                ]),
              ),
              Divider(height: 0),
              Spacer(),
              Container(
                padding: EdgeInsets.fromLTRB(35, 0, 35, 30),
                child: Text(
                    'Thank you for reporting harmful content. You are making this platform a better place. We will review your report very soon.',
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 19),
                    textAlign: TextAlign.center),
              ),
              Spacer()
            ])
          : Container(
              constraints: BoxConstraints.expand(),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Container(
                    width: phoneWidth,
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.fromLTRB(10, 7, 10, 4),
                    child: Row(children: <Widget>[
                      IconButton(
                        constraints: BoxConstraints(),
                        icon: Icon(Icons.close),
                        iconSize: 30,
                        onPressed: () {
                          int count = 0;
                          Navigator.popUntil(context, (route) {
                            return count++ == 1;
                          });
                        },
                      ),
                      Spacer(),
                      Text("Submit a Report", style: Theme.of(context).textTheme.headline5),
                      Spacer(),
                      SizedBox(width: 8),
                      IconButton(
                        constraints: BoxConstraints(),
                        icon: Icon(Icons.send),
                        iconSize: 22,
                        onPressed: () async {
                          // check report isn't empty
                          if (_text.isEmpty) {
                            if (mounted) {
                              setState(() {
                                error = emptyTextError;
                              });
                            }
                            return;
                          }
                          // set to loading screen
                          if (mounted) {
                            setState(() => loading = true);
                          }
                          await ReportsDatabaseService(currUserRef: userData.userRef).newReport(
                              reportType: widget.reportType,
                              entityRef: widget.entityRef,
                              reporterRef: userData.userRef,
                              text: _text);
                          if (mounted) {
                            setState(() {
                              loading = false;
                              submitted = true;
                            });
                          }
                        },
                      )
                    ]),
                  ),
                  Divider(height: 0),
                  error != null
                      ? Container(
                          padding: EdgeInsets.only(top: 12),
                          child: FittedBox(
                              child: Text(error!,
                                  style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.error))))
                      : Container(height: 0),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (textFocusNode.hasFocus) {
                        textFocusNode.unfocus();
                      } else {
                        textFocusNode.requestFocus();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      constraints: BoxConstraints(minHeight: phoneHeight),
                      child: TextField(
                        style: Theme.of(context).textTheme.subtitle1,
                        autocorrect: true,
                        maxLines: null,
                        focusNode: textFocusNode,
                        decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.subtitle1,
                            border: InputBorder.none,
                            hintText: "Description..."),
                        onChanged: (val) {
                          setState(() => _text = val);
                          if (error == emptyTextError) {
                            if (mounted) {
                              setState(() {
                                error = null;
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ]),
              ),
            ),
    );
  }
}
