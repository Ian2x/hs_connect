
import 'package:flutter/material.dart';


class voteCounter extends StatefulWidget {
  const voteCounter({Key? key}) : super(key: key);

  @override
  _voteCounterState createState() => _voteCounterState();
}

class _voteCounterState extends State<voteCounter> {

  int voteCount=0;

  @override
  Widget build(BuildContext context) {

    return Container(
        child:Row(
        children: <Widget> [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: const Icon(Icons.arrow_upward_rounded, size: 13.0),
            tooltip: 'Like',
            onPressed: () {
              setState(() {
                voteCount +=1;
              });
            },
          ),
          Text('$voteCount',
            style: TextStyle(
              fontSize: 12.0,
            )
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: const Icon(Icons.arrow_downward_rounded, size: 13.0),
            tooltip: 'Dislike',
            onPressed: () {
              setState(() {
                voteCount -=1;
              });
            },
          ),
        ]
      )
    );
  }
}
