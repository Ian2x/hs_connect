import 'package:flutter/material.dart';
import 'package:hs_connect/services/storage/image_storage.dart';

import '../constants.dart';

class GroupTag extends StatelessWidget {
  final String? groupImageURL;
  final String groupName;
  final double borderRadius;
  final EdgeInsets padding;
  final double thickness;
  final double fontSize;

  GroupTag({Key? key,
    required this.groupImageURL,
    required this.groupName,
    required this.borderRadius,
    required this.padding,
    required this.thickness,
    required this.fontSize
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      labelPadding: EdgeInsets.all(0),
      padding: EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Container(
          decoration: BoxDecoration(
              gradient: Gradients.blueRed(),
              borderRadius: BorderRadius.circular(borderRadius)
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Theme.of(context).colorScheme.surface,
            ),
            margin: EdgeInsets.all(thickness),
            child: Row(children: <Widget>[
              groupImageURL!=null ? Container(
                height: fontSize*1.5,
                width: fontSize*1.5,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: ImageStorage().groupImageProvider(groupImageURL),
                      fit: BoxFit.fill,
                    )
                ),
              ) : Container(),
              groupImageURL!=null ? SizedBox(width: fontSize/6) : Container(),
              Container(
                padding: EdgeInsets.only(bottom: 2),
                child: Text( groupName,
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: fontSize)
                ),
              )
            ]),
          )
      ),
    );
/*
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(fontSize/2,fontSize/2.5,fontSize/2,fontSize/2.5),
      decoration: ShapeDecoration(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(fontSize/2),
            ),
      ),
      child: Row(
        children: [
          groupImageURL!=null ? Container(
            height: fontSize * 1.5,
            width: fontSize * 1.5,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: ImageStorage().groupImageProvider(groupImageURL),
                  fit: BoxFit.fill,
                )
            ),
          ) : Container(),
          groupImageURL!=null ? SizedBox(width: fontSize / 3) : Container(),
          Text( groupName,
            style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: fontSize, color: groupColor != null ? groupColor : colorScheme.onSurface)
          )
        ],
      )
    );*/
  }
}
