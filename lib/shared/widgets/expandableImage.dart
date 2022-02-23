import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'loading.dart';

class ExpandableImage extends StatefulWidget {
  final String imageURL;
  final double containerWidth;
  final double maxHeight;
  final double loadingHeight;
  final EdgeInsets? margin;
  ExpandableImage ({Key? key,
    required this.imageURL,
    required this.containerWidth,
    this.maxHeight = 450,
    this.loadingHeight = 450,
    this.margin
  }) : super(key: key);

  @override
  _ExpandableImageState createState() => _ExpandableImageState();
}

class _ExpandableImageState extends State<ExpandableImage> {

  final GlobalKey dismissKey = GlobalKey();
  final GlobalKey imageKey = GlobalKey();
  final imageTag = UniqueKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MyTransparentRoute(builder: (context) {
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
                          child: CachedNetworkImage(
                              imageUrl: widget.imageURL,
                              fit: BoxFit.contain
                          )
                      ),
                    ),
                  ),
                ),
              );
            },
            )
        );
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
            placeholder: (context, url) => Container(height: 300, width: widget.containerWidth, color: Colors.black, child: Loading()),
          )
        ),
      ),
    );
  }
}
