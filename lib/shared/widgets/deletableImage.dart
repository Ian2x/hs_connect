import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

class DeletableImage extends StatelessWidget {
  final Image image;
  final VoidFunction onDelete;
  final double containerWidth;
  final double maxHeight;

  const DeletableImage({Key? key, required this.image, required this.onDelete, required this.containerWidth, required this.maxHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);}));

    final sizing = min(containerWidth, maxHeight) * 0.07 + 15;
    return FutureBuilder(
      future: completer.future,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Container(
              width: containerWidth,
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                image: DecorationImage(image: image.image)
              )
          );
        } else {
          final origWidth = snapshot.data.width;
          final origHeight = snapshot.data.height;
          final scale = min(containerWidth / origWidth, maxHeight / origHeight);
          final newWidth = origWidth * scale;
          final newHeight = origHeight * scale;
          final sizing = min<double>(newWidth, newHeight) * 0.07 + 15;
          return Container(
            width: newWidth,
            height: newHeight,
            //color: Colors.purple,
            child: Stack(
              children: [
                Container(
                  width: newWidth,
                  height: newHeight,
                  child: image
                ),
                Positioned(
                    right: sizing/3,
                    top: sizing/3,
                    child: DeleteImageButton(onDelete: onDelete, buttonSize: sizing))
              ],
            ),
          );
        }
      },
    );
    return Container(
      width: containerWidth,
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Stack(
        children: [
          Container(
            width: containerWidth,
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: image.image)
              ),
            ),
          ),
          Positioned(
              right: sizing/3,
              top: sizing/3,
              child:DeleteImageButton(onDelete: onDelete, buttonSize: sizing))
        ],
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