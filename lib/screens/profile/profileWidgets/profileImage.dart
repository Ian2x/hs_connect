import 'package:flutter/material.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class ProfileImage extends StatelessWidget {
  final String currUserName;
  final bool showEditIcon;
  final String? profileImageURL;
  final ImageStorage _images = ImageStorage();

  ProfileImage({
    Key? key,
    required this.currUserName,
    required this.showEditIcon,
    required this.profileImageURL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
          width: 100*hp,
          height: 100*hp,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.background,
              border: Border.all(color: colorScheme.background, width: 1.5*hp),
              image: DecorationImage(fit: BoxFit.fill, image: _images.profileImageProvider(profileImageURL))
          )
      ),
    );
  }

}
