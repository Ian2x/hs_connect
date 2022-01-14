import 'package:flutter/material.dart';

IconButton myBackButtonIcon(BuildContext context) {
  return IconButton(
    icon: Icon(Icons.arrow_back_ios, color: Colors.black),
    onPressed: () => Navigator.of(context).pop(),
  );
}
