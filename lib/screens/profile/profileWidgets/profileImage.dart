import 'package:flutter/material.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class ProfileImage extends StatelessWidget {
  final String currUserName;
  final bool showEditIcon;
  final Color? background;
  double? size;

  ProfileImage({
    Key? key,
    required this.currUserName,
    required this.showEditIcon,
    required this.background,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    final widthP= size != null ? size : 60*hp;

    return
      Container(
      child: Stack(
        children: [
          Container(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
              width: widthP,
              height: widthP,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: background,
                  border: Border.all(color: colorScheme.background, width: 1.5*hp),
              )
          ),
          Positioned(
            left:widthP!*.53,
            top:widthP*.2,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:widthP*.6,
                maxHeight: widthP*.6,
              ),
              child:Image.asset("assets/sublogo2.png"),
            ),
          ),
        ],
      ),
    );
  }

}
