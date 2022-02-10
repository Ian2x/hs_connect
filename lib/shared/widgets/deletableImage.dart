import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

class DeletableImage extends StatelessWidget {
  final Image image;
  final VoidFunction onDelete;
  final double width;
  final double height;

  const DeletableImage({Key? key, required this.image, required this.onDelete, required this.width, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    final sizing = min(width, height) * 0.07 + 15;
    return Container(
      height: height,
      width: width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: width, height: height, alignment: Alignment.center, child: Stack(
            children: [
              image,
              Positioned(
                  right: sizing/3,
                  top: sizing/3,
                  child:DeleteImageButton(onDelete: onDelete, buttonSize: sizing))
            ],
          )),
        ]
      ),
    );
  }
}

class DeleteImageButton extends StatelessWidget {
  final VoidFunction onDelete;
  final double buttonSize;
  const DeleteImageButton({Key? key, required this.onDelete, required this.buttonSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: new BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
          child: Icon(Icons.close, color: Colors.white, size: buttonSize*0.8)),
      onTap: onDelete,
    );
  }
}