import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int scoreCount;

  ProfileStats({Key? key, required this.scoreCount}) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            scoreCount.toString() + ' Points',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          VerticalDivider(),
          Text(
              ' something',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      );
}
