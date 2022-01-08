import 'package:flutter/material.dart';
import 'package:hs_connect/screens/profile/profileWidget/buttonWidget.dart';
import 'package:hs_connect/screens/profile/profileWidget/profileFormPage.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';

import '../profileForm.dart';

class ProfileWidget extends StatelessWidget {
  final VoidCallback onClicked;
  final String? profileImage;
  final String currUserName;

  const ProfileWidget({
    Key? key,
    required this.profileImage,
    required this.onClicked,
    required this.currUserName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = HexColor('787878');// Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(color, context),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: profileImage == null
              ? NetworkImage(
                  "https://media.vanityfair.com/photos/5c82940e52ce6720b360804c/1:1/w_1482,h_1482,c_limit/elon-musk-security-clearance.jpg")
              : NetworkImage(profileImage!),
          fit: BoxFit.cover,
          width: 84,
          height: 84,
          //child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color, BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileFormPage(
                profileForm: (ProfileForm(currDisplayName: currUserName, currImageURL: profileImage)),
              )));
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
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
