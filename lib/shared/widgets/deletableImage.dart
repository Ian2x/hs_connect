import 'package:flutter/material.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

class DeletableImage extends StatelessWidget {
  final Image image;
  final VoidFunction onDelete;
  final double width;
  final double height;
  final double buttonSize;

  const DeletableImage({Key? key, required this.image, required this.onDelete, required this.width, required this.height, required this.buttonSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Stack(
            children: [
              image,
              Positioned(
                right: 10,
                top: 10,
                child:DeleteImageButton(onDelete: onDelete, buttonSize: buttonSize))
            ]
          ),
        ));
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
        height: buttonSize,
        width: buttonSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: new BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
            ),
            Icon(Icons.close, color: Colors.white),
          ],
        ),
      ),
      onTap: onDelete,
    );
  }
}