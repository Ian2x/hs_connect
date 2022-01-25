import 'package:flutter/material.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:provider/provider.dart';

class ProfileName extends StatelessWidget {
  final String name;
  final String domain;
  const ProfileName({Key? key, required this.name, required this.domain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;

    return Column(
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.headline5,
        ),
        SizedBox(height: 4*hp),
      ],
    );
  }
}
