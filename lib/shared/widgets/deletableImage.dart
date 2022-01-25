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
        child: Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(builder: (BuildContext context) {
              return FittedBox(
                child: image,
                fit: BoxFit.fill,
              );
            }),
            OverlayEntry(builder: (BuildContext context) {
              return Row(children: <Widget>[
                Spacer(),
                Column(children: <Widget>[
                  SizedBox(height: buttonSize/3),
                  DeleteImageButton(onDelete: onDelete, buttonSize: buttonSize),
                  Spacer()
                ]),
                SizedBox(width: buttonSize/3),
              ]);
            }),
          ],
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
            Icon(Icons.close,
            color: Colors.white),
          ],
        ),
      ),
      onTap: onDelete,
    );
  }
}