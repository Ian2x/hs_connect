import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pixels.dart';

class ImageContainer extends StatelessWidget {

  final String imageString;

  ImageContainer ({Key? key, required this.imageString}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;

    return Container(
    margin: EdgeInsets.only(left: 5*wp, right: 5*wp, top: 10*hp, bottom: 0),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(imageString),
        ],
      )

    );
  }
}
