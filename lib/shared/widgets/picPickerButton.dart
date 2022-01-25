import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';

IconButton picPickerButton(
    {required Function setPic, required double iconSize, required double maxHeight, required double maxWidth, imageQuality = 100, Color? color, required BuildContext context}) {
  final colorScheme = Theme.of(context).colorScheme;
  final wp = MediaQuery.of(context).size.width / numWidthPixels;
  return IconButton(
    icon: Icon(Icons.photo),
    iconSize: iconSize,
    constraints: BoxConstraints(),
    padding: EdgeInsets.only(left: 5*wp, right: 5*wp),
    color: color != null ? color : colorScheme.onError,
    onPressed: () async {
      try {
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          imageQuality: imageQuality,
        );
        if (pickedFile != null) {
          setPic(File(pickedFile.path));
        } else {
          setPic(null);
        }
      } catch (e) {
        print(e);
      }
    },
  );
}
