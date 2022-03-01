import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'loading.dart';

class ExpandableImage extends StatefulWidget {
  final String imageURL;
  final double containerWidth;
  final double maxHeight;
  final EdgeInsets? margin;

  ExpandableImage(
      {Key? key,
      required this.imageURL,
      required this.containerWidth,
      this.maxHeight = 450,
      this.margin})
      : super(key: key);

  @override
  _ExpandableImageState createState() => _ExpandableImageState();
}

class _ExpandableImageState extends State<ExpandableImage> {
  final GlobalKey dismissKey = GlobalKey();
  final GlobalKey imageKey = GlobalKey();
  final imageTag = UniqueKey();
  final transformationController = TransformationController();
  late TapDownDetails doubleTapDetails;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (transformationController.value != Matrix4.identity()) {
      transformationController.value = Matrix4.identity();
    } else {
      final position = doubleTapDetails.localPosition;
      // For a 3x zoom
      transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MyTransparentRoute(
          builder: (context) {
            return DismissiblePage(
              direction: DismissDirection.vertical,
              onDismiss: () => Navigator.pop(context),
              key: dismissKey,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Hero(
                  tag: imageTag,
                  child: GestureDetector(
                    onDoubleTap: _handleDoubleTap,
                    onDoubleTapDown: _handleDoubleTapDown,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: InteractiveViewer(
                          key: imageKey,
                          minScale: 1,
                          maxScale: 6,
                          transformationController: transformationController,
                          child: CachedNetworkImage(imageUrl: widget.imageURL, fit: BoxFit.contain)),
                    ),
                  ),
                ),
              ),
            );
          },
        ));
      },
      child: Hero(
        tag: imageTag,
        child: Container(
            width: widget.containerWidth,
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            margin: widget.margin,
            color: Colors.black,
            child: CachedNetworkImage(
              imageUrl: widget.imageURL,
              fit: BoxFit.contain,
              fadeInDuration: Duration(milliseconds: 1500),
              fadeInCurve: Curves.easeInExpo,
              placeholder: (context, url) => Container(
                  height: 300,
                  width: widget.containerWidth,
                  color: Colors.black,
                  child: Loading(
                    backgroundColor: Colors.black,
                  )),
            )),
      ),
    );
  }
}
