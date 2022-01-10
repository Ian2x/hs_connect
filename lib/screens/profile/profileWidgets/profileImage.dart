import 'package:flutter/material.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';

import '../profileForm.dart';

class ProfileImage extends StatelessWidget {
  final String currUserName;
  final bool showEditIcon;
  final Widget profileImage;
  final String? profileImageString;

  const ProfileImage({
    Key? key,
    required this.currUserName,
    required this.showEditIcon,
    required this.profileImage,
    required this.profileImageString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = HexColor('787878'); // Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          showEditIcon ? Positioned(
            bottom: -2,
            right: -2,
            child: buildEditIcon(color, context),
          ) : Container(),
        ],
      ),
    );
  }

  Widget buildImage() {

    Widget content = profileImage;
    if (profileImageString == null) {
      content = buildDefaultImage();
    }
    return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white54,
            border: Border.all(color: Colors.black, width: 1),
            image: content is Image
                ? DecorationImage(
                    fit: BoxFit.fill,
                    image: content.image,
                  )
                : null),
        child: content is Image ? null : content);
  }

  Widget buildEditIcon(Color color, BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ProfileForm(currDisplayName: currUserName, currImageURL: profileImageString)),
          );
        },
        child: buildCircle(
          color: Colors.white,
          all: 3,
          child: buildCircle(
            color: color,
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
