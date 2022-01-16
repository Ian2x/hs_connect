import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

class GroupTag extends StatelessWidget {
  // TODO: use circleFromGroup (which uses myCircle) instead of groupImage
  // NOTE: use circleFromGroup takes in a group, not groupImage and groupName
  Image? groupImage;
  String groupName;
  Color? groupColor;

  GroupTag({Key? key,
    required this.groupImage,
    required this.groupName,
    this.groupColor,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(5.0,0.0,5.0,0.0),
      decoration: ShapeDecoration(
        color: ThemeColor.lightGrey,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            ),
      ),
      child: Row(
        children: [
          Container(
            height: 33,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: groupImage!.image,
                  fit: BoxFit.fill,
                )
            ),
          ),
          SizedBox(width:3),
          Text( groupName,
            style:ThemeText.regularSmall(fontSize:14.0,
              color: groupColor,
            ),
          )
        ],
      )
    );
  }
}
