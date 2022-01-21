import 'package:flutter/material.dart';

class imageContainer extends StatelessWidget {

  String imageString;

  imageContainer ({Key? key, required this.imageString}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
    margin: const EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0, bottom: 0.0),
    child:Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(imageString),
        ],
      )

    );
  }
}
