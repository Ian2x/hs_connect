import 'package:flutter/material.dart';

class Wheel extends StatefulWidget {
  @override
  _WheelState createState() => _WheelState();
}
class _WheelState extends State<Wheel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geeksforgeeks"),
        backgroundColor: Colors.green,
      ),
      body: ListWheelScrollView.useDelegate(
        itemExtent: 20,
        useMagnifier: true,
        magnification: 2,
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List<Widget>.generate(
            10, (index) => Text('${index + 1}'),
          )
        ),
        clipBehavior: Clip.hardEdge,
      ),
    );
  }
}
