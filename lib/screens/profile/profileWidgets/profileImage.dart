import 'package:flutter/material.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/tools/buildCircle.dart';
import 'profileForm.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Stack(
        children: [
          buildImage(context: context),
          Positioned(
            bottom: -2,
            right: -2,
            child: showEditIcon ? buildEditIcon(colorScheme.primary, context) : Container(),
          )
        ],
      ),
    );
  }

  Widget buildImage({required BuildContext context}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.background,
            border: Border.all(color: colorScheme.background, width: 1.5),
            image: DecorationImage(fit: BoxFit.fill, image: _images.profileImageProvider(profileImageURL))
        )
    );
  }

  Widget buildEditIcon(Color color, BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => pixelProvider(context, child: ProfileForm(currDisplayName: currUserName, currImageURL: profileImageURL))),
          );
        },
        child: buildProfileCircle(
          color: Theme.of(context).colorScheme.surface,
          all: 3,
          child: buildProfileCircle(
            color: Theme.of(context).colorScheme.secondary,
            all: 8,
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 10,
            ),
          ),
        ),
      );
}
