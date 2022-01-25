import 'package:flutter/material.dart';

class GroupTag extends StatelessWidget {
  final Image? groupImage;
  final String groupName;
  final Color? groupColor;
  final double fontSize;

  GroupTag({Key? key,
    required this.groupImage,
    required this.groupName,
    required this.fontSize,
    required this.groupColor,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
          groupImage!=null ? Container(
            height: fontSize * 1.5,
            width: fontSize * 1.5,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: groupImage!.image,
                  fit: BoxFit.fill,
                )
            ),
          ) : Container(),
          groupImage!=null ? SizedBox(width: fontSize / 3) : Container(),
          Text( groupName,
            style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: fontSize, color: groupColor != null ? groupColor : colorScheme.onSurface)
          )
        ],
      )
    );
  }
}
