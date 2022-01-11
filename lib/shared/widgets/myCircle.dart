import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  final Widget child;
  final Color textBackgroundColor;
  final double size;

  const Circle({Key? key, required this.child, required this.textBackgroundColor, this.size=200}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: textBackgroundColor,
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
          image: child is Image
              ? DecorationImage(
            fit: BoxFit.fill,
            image: (child as Image).image,
          )
              : null,
        ),
        child: child is Image ? null : Center(child: child));
  }
}