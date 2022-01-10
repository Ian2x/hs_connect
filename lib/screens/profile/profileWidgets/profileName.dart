import 'package:flutter/material.dart';

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(domain,
          style: TextStyle(color: Colors.black),
        )
      ],
    );
  }
}
