import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:tuple/tuple.dart';

class ExpandableImage extends StatefulWidget {
  final String imageURL;
  final double containerWidth;
  final double maxHeight;
  final double loadingHeight;
  final EdgeInsets? margin;
  ExpandableImage ({Key? key,
    required this.imageURL,
    required this.containerWidth,
    this.maxHeight = double.infinity,
    this.loadingHeight = 450,
    this.margin
  }) : super(key: key);

  @override
  _ExpandableImageState createState() => _ExpandableImageState();
}

class _ExpandableImageState extends State<ExpandableImage> {

  ImageProvider? imageProvider;
  double? finalHeight;
  final GlobalKey dismissKey = GlobalKey();
  final GlobalKey imageKey = GlobalKey();
  final imageTag = UniqueKey();

  @override
  void initState() {
    _calculateImageDimension();
    super.initState();
  }

  void _calculateImageDimension() async {
    final tuple = await compute(_calculateImageDimensionHelper, widget.imageURL);
    double widthRatio = widget.containerWidth / tuple.item2.width;
    double heightRatio = widget.maxHeight / tuple.item2.height;
    double? tempHeight;
    if (widthRatio > heightRatio) {
      // height limited
      tempHeight = widget.maxHeight;
    } else {
      // width limited
      tempHeight = tuple.item2.height * widthRatio;
    }
    if (mounted) {
      setState(() {
        imageProvider = tuple.item1;
        finalHeight = tempHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (finalHeight!=null && imageProvider!=null){
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              TransparentRoute(builder: (context) {
                return DismissiblePage(
                  direction: DismissDirection.vertical,
                  onDismiss: ()=>Navigator.pop(context),
                  key: dismissKey,
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Hero(
                      tag: imageTag,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: InteractiveViewer(
                            key: imageKey,
                            minScale: 1,
                            maxScale: 4,
                            onInteractionEnd: (ScaleEndDetails sed) {
                            },
                            onInteractionStart: (ScaleStartDetails ssd) {
                            },
                            onInteractionUpdate: (ScaleUpdateDetails sud) {
                            },
                            child: ImageStorage().getCachedImage(widget.imageURL, fit: BoxFit.contain)
                        ),
                      ),
                    ),
                  ),
                );
                }, backgroundColor: Colors.transparent
              )
          );
        },
        child: Hero(
          tag: imageTag,
          child: Container(
            width: widget.containerWidth,
            height: finalHeight!,
            margin: widget.margin,
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: imageProvider!,
              ),
            ),
          ),
        ),
      );}
    else {
      return Container(width: widget.containerWidth, height: widget.loadingHeight, color: Colors.black);
    }
  }
}

Future<Tuple2<ImageProvider, Size>> _calculateImageDimensionHelper(String imageURL) {
  Completer<Tuple2<ImageProvider, Size>> completer = Completer();
  final imageProvider = CachedNetworkImageProvider(imageURL);
  imageProvider.resolve(ImageConfiguration()).addListener(
    ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {
        final myImage = image.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(Tuple2<ImageProvider, Size>(imageProvider, size));
      },
    ),
  );
  return completer.future;
}