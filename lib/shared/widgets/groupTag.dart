import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

class GroupTag extends StatelessWidget {
  // TODO: use circleFromGroup (which uses myCircle) instead of groupImage
  // NOTE: use circleFromGroup takes in a group, not groupImage and groupName
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
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(fontSize/2,fontSize/2.5,fontSize/2,fontSize/2.5),
      decoration: ShapeDecoration(
        color: ThemeColor.lightGrey,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(fontSize/1.5),
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
            style:ThemeText.regularSmall(fontSize: fontSize,
              color: groupColor,
            ),
          )
        ],
      )
    );
  }
}
