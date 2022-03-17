import 'package:flutter/material.dart';


class ModalTab extends StatelessWidget {

  final double? bottomMargin;

  const ModalTab({
    this.bottomMargin,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Color color= Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.fromLTRB(0, 15, 0,
          bottomMargin ?? 25),
      height:3,
      width: MediaQuery.of(context).size.width*.1,
      decoration: BoxDecoration(
          border: Border.all(
            color: color,
          ),
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),
    );
  }
}
