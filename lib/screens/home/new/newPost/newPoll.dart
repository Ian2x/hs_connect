import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

class NewPoll extends StatefulWidget {
  const NewPoll({Key? key}) : super(key: key);

  @override
  _NewPollState createState() => _NewPollState();
}

class _NewPollState extends State<NewPoll> {
  final _formKey = GlobalKey<FormState>();
  int numOptions = 2;
  List<String> choices = List.filled(2, '');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        border: Border.all(color: ThemeColor.mediumGrey),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(0),
      child: Form(
        key: _formKey,
        child: ListView.builder(
          itemCount: numOptions,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: TextFormField(
                style: TextStyle(
                  color: HexColor("223E52"),
                  fontSize: 22,
                ),
                maxLength: 42,

              )
            );
          },
        ),
      )
    );
  }
}
