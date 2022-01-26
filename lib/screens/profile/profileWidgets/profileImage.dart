import 'package:flutter/material.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import '../profileForm.dart';

class ProfileImage extends StatelessWidget {
  final String currUserName;
  final bool showEditIcon;
  final Widget profileImage;
  final String? profileImageURL;

  const ProfileImage({
    Key? key,
    required this.currUserName,
    required this.showEditIcon,
    required this.profileImage,
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
            image: profileImage is Image
                ? DecorationImage(
                    fit: BoxFit.fill,
                    image: (profileImage as Image).image,
                  )
                : null),
        child: profileImage is Image ? null : profileImage);
  }

  Widget buildEditIcon(Color color, BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => pixelProvider(context, child: ProfileForm(currDisplayName: currUserName, currImageURL: profileImageURL))),
          );
        },
        child: buildCircle(
          color: Theme.of(context).colorScheme.surface,
          all: 3,
          child: buildCircle(
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

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(all),
        color: color,
        child: child,
      ),
    );
  }

  Widget buildDefaultImage() {
    return Icon(Icons.person);
  }
}
