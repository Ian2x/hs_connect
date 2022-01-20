import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';

class ProfileName extends StatelessWidget {
  final String name;
  final String domain;
  const ProfileName({Key? key, required this.name, required this.domain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: ThemeText.groupBold(fontSize: 22),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
