import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/report.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/reports_database.dart';
import 'package:provider/provider.dart';

import '../pixels.dart';
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

  late FocusNode myFocusNode;
  final _formKey = GlobalKey<FormState>();

  void handleError(err) {
    if (mounted) {
      setState(() {
        error = 'ERROR: something went wrong while submitting report';
      });
    }
  }

  void handleValue(val) {
    Navigator.pop(context);
  }

  String _text = '';
  String? error;

  bool loading = false;
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    double phoneHeight = MediaQuery.of(context).size.height;
    double phoneWidth = MediaQuery.of(context).size.width;

    final userData = Provider.of<UserData?>(context);
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;


    if (userData == null || loading) {
      return Container(
          height: phoneHeight * 0.6 + MediaQuery.of(context).viewInsets.bottom,
          decoration: BoxDecoration(
              color: colorScheme.background,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20*hp), topRight: Radius.circular(20*hp))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: phoneWidth,
              constraints: BoxConstraints(),
              padding: EdgeInsets.fromLTRB(10*wp, 7*hp, 10*wp, 4*hp),
              child: Row(children: <Widget>[
                IconButton(
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.close),
                  color: Colors.transparent,
                  iconSize: 30*hp,
                  onPressed: () {},
                ),
              ]),
            ),
            Divider(height: 0),
            Spacer(),
            Loading(),
            Spacer(),
            SizedBox(height: 30*hp)
          ]));
    }
    if (submitted) {
      return Container(
          height: phoneHeight * 0.6 + MediaQuery.of(context).viewInsets.bottom,
          decoration: BoxDecoration(
              color: colorScheme.background,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20*hp), topRight: Radius.circular(20*hp))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: phoneWidth,
              constraints: BoxConstraints(),
              padding: EdgeInsets.fromLTRB(10*wp, 7*hp, 10*wp, 4*hp),
              child: Row(children: <Widget>[
                IconButton(
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.close),
                  iconSize: 30*hp,
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
                SizedBox(width: 30*wp)
              ]),
            ),
            Divider(height: 0),
            Spacer(),
            Container(
              padding: EdgeInsets.fromLTRB(35*wp, 0, 35*wp, 30*hp),
              child: Text(
                  'Thank you for reporting harmful content. You are making this platform a better place. We will review your report very soon.',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 19),
                  textAlign: TextAlign.center),
            ),
            Spacer()
          ]));
    }

    return Container(
      height: phoneHeight * 0.6 + MediaQuery.of(context).viewInsets.bottom,
      decoration: BoxDecoration(
          color: colorScheme.background,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20*hp), topRight: Radius.circular(20*hp))),
      child: Form(
        key: _formKey,
        child: Column(children: <Widget>[
          Container(
            width: phoneWidth,
            constraints: BoxConstraints(),
            padding: EdgeInsets.fromLTRB(10*wp, 7*hp, 10*wp, 4*hp),
            child: Row(children: <Widget>[
              IconButton(
                constraints: BoxConstraints(),
                icon: Icon(Icons.close),
                iconSize: 30*hp,
                onPressed: () {
                  int count = 0;
                  Navigator.popUntil(context, (route) {
                    return count++ == 2;
                  });
                },
              ),
              Spacer(),
              Text("Submit a Report", style: Theme.of(context).textTheme.headline5),
              Spacer(),
              SizedBox(width: 8*wp),
              IconButton(
                constraints: BoxConstraints(),
                icon: Icon(Icons.send),
                iconSize: 22*hp,
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
                  if (_formKey.currentState != null && _formKey.currentState!.validate()) {
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
                  }
                },
              )
            ]),
          ),
          Divider(height: 0),
          error != null
              ? Container(
                  padding: EdgeInsets.only(top: 12*hp),
                  child: Text(error!, style: Theme.of(context).textTheme.subtitle1?.copyWith(color: colorScheme.error)))
              : Container(height: 0),
          Container(
            padding: EdgeInsets.fromLTRB(15*wp, 0, 15*wp, 0),
            child: TextFormField(
              style: Theme.of(context).textTheme.subtitle1,
              maxLines: 15,
              autocorrect: false,
              maxLength: 400,
              decoration: InputDecoration(
                  hintStyle: Theme.of(context).textTheme.subtitle1, border: InputBorder.none, hintText: "Description..."),
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
        ]),
      ),
    );
  }
}
