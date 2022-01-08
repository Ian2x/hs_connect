import 'package:flutter/material.dart';

class NumbersWidget extends StatelessWidget {
  final int groupCount;
  final int scoreCount;

  NumbersWidget({Key? key, required this.scoreCount, required this.groupCount}) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, scoreCount.toString() + ' Points', 'Points'),
          buildDivider(),
          buildButton(context, groupCount.toString() + ' Groups', 'Groups'),
        ],
      );

  Widget buildDivider() => Container(
        height: 2,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) => MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            /*SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),*/
          ],
        ),
      );
}
