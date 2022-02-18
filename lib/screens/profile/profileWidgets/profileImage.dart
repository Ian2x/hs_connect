import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final Color? background;
  final double? size;

  ProfileImage({
    Key? key,
    required this.background,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    Image logoImage;

    final widthP= size != null ? size : 60;

    if (background != null){
      logoImage = Image.asset("assets/sublogo2.png");
    } else {
      logoImage = Image.asset("assets/images/defaultgroupimage1.png");
    }


    return
      Container(
      width: size != null ? size : 60,
      height: size != null ? size : 60,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Center(
            child: Container(
                width: size != null ? size : 60,
                height: size != null ? size : 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: background != null ? background: colorScheme.surface,
                    border: Border.all(color: colorScheme.background, width: 1.5),
                )
            ),
          ),
          Positioned(
            left:widthP!*.23,
            top:widthP*.2,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:widthP*.55,
                maxHeight: widthP*.55,
              ),
              child:logoImage,
            ),
          ),
        ],
      ),
    );
  }

}
