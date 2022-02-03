import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

const maxNumOptions = 6;

class NewPoll extends StatefulWidget {
  final VoidFunction onDeletePoll;
  final VoidPollDataParamFunction onUpdatePoll;
  final VoidFunction onAddPollChoice;

  const NewPoll({Key? key, required this.onDeletePoll, required this.onUpdatePoll, required this.onAddPollChoice})
      : super(key: key);

  @override
  _NewPollState createState() => _NewPollState();
}

class _NewPollState extends State<NewPoll> {
  final _formKey = GlobalKey<FormState>();
  int numOptions = 2;
  List<String> choices = [];
  List<int> choicesLengths = [];

  @override
  void initState() {
    for (int i = 0; i < 2; i++) {
      choices.add('');
      choicesLengths.add(0);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5*hp),
            side: BorderSide(
              color: colorScheme.onError,
              width: 1*hp,
            ),
          ),
        ),
        padding: EdgeInsets.all(10*hp),
        margin: EdgeInsets.all(0),
        child: Form(
          key: _formKey,
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: min(numOptions + 2, 7),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.all(0),
                    constraints: BoxConstraints(),
                    onPressed: () {
                      widget.onDeletePoll();
                    },
                    icon: Icon(Icons.close),
                  )
                ]);
              } else if (index == numOptions + 1) {
                return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.all(0),
                    constraints: BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        choices.add('');
                        choicesLengths.add(0);
                        numOptions += 1;
                      });
                      widget.onAddPollChoice();
                    },
                    icon: Icon(Icons.add),
                  )
                ]);
              } else {
                int trueIndex = index - 1;
                return Container(
                    margin: EdgeInsets.all(5*hp),
                    padding: EdgeInsets.only(left: 5*wp, right: 5*wp),
                    decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(
                        color: colorScheme.onError,
                        width: 1*hp,
                      ),
                    )),
                    child: TextFormField(
                        autocorrect: false,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(25),
                        ],
                        style: Theme.of(context).textTheme.subtitle2,
                        maxLines: 1,
                        decoration: InputDecoration(
                            suffixText: '${choicesLengths[trueIndex].toString()}/${25.toString()}',
                            suffixStyle: Theme.of(context).textTheme.subtitle2,
                            hintStyle: Theme.of(context).textTheme.subtitle1,
                            border: InputBorder.none,
                            hintText: "Option " + (trueIndex + 1).toString()),
                        validator: (val) {
                          if (val == null) return 'Error: null value';
                          if (val.isEmpty)
                            return 'Can\'t create a poll with empty choice';
                          else
                            return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            choices[trueIndex] = val;
                            choicesLengths[trueIndex] = val.length;
                          });
                          widget.onUpdatePoll(trueIndex, val);
                        }));
              }
            },
          ),
        ));
  }
}
