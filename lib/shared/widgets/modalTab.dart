import 'package:flutter/material.dart';


class modalTab extends StatelessWidget {

  final double? bottomMargin;

  const modalTab({
    this.bottomMargin,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Color color= Theme.of(context).colorScheme.primaryVariant;

    return Container(
      margin: EdgeInsets.fromLTRB(0, 15, 0,
          bottomMargin != null ? bottomMargin! : 25),
      height:3,
      width: MediaQuery.of(context).size.width*.2,
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
