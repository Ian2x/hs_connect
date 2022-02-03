import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:provider/provider.dart';

import '../pixels.dart';
import 'loading.dart';

class ImageContainer extends StatefulWidget {
  final String imageString;
  final double containerWidth;
  final double hp;
  final ImageStorage _images = ImageStorage();
  ImageContainer ({Key? key,
    required this.imageString,
    required this.containerWidth,
    required this.hp,
  }) : super(key: key);




  @override
  _ImageContainerState createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {

  late Size imageDimension;
  bool asyncDone=false;
  late double imageRatio;
  late Image postImage;
  bool longPortrait = false;


  Future<Size> _calculateImageDimension() {
    Completer<Size> completer = Completer();
    postImage = new Image(image: CachedNetworkImageProvider(widget.imageString)); // I modified this line
    postImage.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }

  double heightConstant=0.0;
  double containerHeight= 0.0;



  void calculateExtra(size) {
    if (mounted){
      setState((){
        imageDimension = size;
        imageRatio= imageDimension.width/imageDimension.height;
        if (imageRatio < .5){
          longPortrait =true;
        }
        heightConstant= (widget.containerWidth)/imageDimension.width;
        if (!longPortrait){
          containerHeight = imageDimension.height*heightConstant;
        } else {
          containerHeight= 450 *widget.hp;
        }
        asyncDone=true;
      });
    }
  }

  @override
  void initState() {
    _calculateImageDimension().then(
        (size)=> calculateExtra(size)
    );

    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    // 487.0,696.0

    if (asyncDone){
      return Container(
          width: MediaQuery.of(context).size.width,
          height:containerHeight,
          /*constraints: BoxConstraints(
            minHeight: imageDimension.height*heightConstant,
            maxHeight: double.infinity,
          ),*//**/
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              fit: longPortrait != true ? BoxFit.fitWidth: BoxFit.fitHeight,
              image: postImage.image,
            ),
          ),
          margin: EdgeInsets.only(top: 10*widget.hp),
          padding: EdgeInsets.zero,
          /*child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              *//*Text(imageRatio.toString(), style: TextStyle(color: Colors.pink)),
              Text("isPotrait:" + longPortrait.toString(), style: TextStyle(color: Colors.pink)),*//*
              FittedBox(
                child: postImage,
                fit: longPortrait != true ? BoxFit.fitWidth: BoxFit.fitHeight,
              )
            ],
          )*/
      );}
      else {
        return Container(color: Theme.of(context).colorScheme.onSurface);
    }
  }
}

