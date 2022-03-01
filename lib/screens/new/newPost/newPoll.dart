import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(
              color: colorScheme.onError,
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.zero,
        child: Form(
          key: _formKey,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: min(numOptions + 2, 7),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.zero,
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
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          choices.add('');
                          choicesLengths.add(0);
                          numOptions += 1;
                        });
                        widget.onAddPollChoice();
                      }
                    },
                    icon: Icon(Icons.add),
                  )
                ]);
              } else {
                int trueIndex = index - 1;
                return Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.only(left: 5, right: 5),
                    decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(
                        color: colorScheme.onError,
                        width: 1,
                      ),
                    )),
                    child: TextFormField(
                        autocorrect: true,
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
                          if (mounted) {
                            setState(() {
                              choices[trueIndex] = val;
                              choicesLengths[trueIndex] = val.length;
                            });
                            widget.onUpdatePoll(trueIndex, val);
                          }
                        }));
              }
            },
          ),
        ));
  }
}
