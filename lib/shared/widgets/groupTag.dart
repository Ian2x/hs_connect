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
  final Color? groupColor;

  GroupTag({Key? key,
    required this.groupImageURL,
    required this.groupName,
    required this.borderRadius,
    required this.padding,
    required this.thickness,
    required this.fontSize,
    required this.groupColor
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      labelPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Container(
          decoration: BoxDecoration(
              gradient: groupColor==null ? Gradients.blueRed() : null,
              color: groupColor!=null ? groupColor : null,
              borderRadius: BorderRadius.circular(borderRadius)
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius-thickness),
              color: colorScheme.surface,
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
              groupImageURL!=null ? SizedBox(width: fontSize*0.4) : Container(),
              Container(
                padding: EdgeInsets.only(bottom: 0),
                child: Text( groupName,
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: fontSize)
                ),
              )
            ]),
          )
      ),
    );
  }
}
