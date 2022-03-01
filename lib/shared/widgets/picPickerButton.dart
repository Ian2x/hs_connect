import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

IconButton picPickerButton(
    {required Function setPic,
    required double iconSize,
    required double maxHeight,
    required double maxWidth,
    imageQuality = 100,
    Color? color,
    required BuildContext context}) {
  final colorScheme = Theme.of(context).colorScheme;
  return IconButton(
    icon: Icon(Icons.photo),
    iconSize: iconSize,
    constraints: BoxConstraints(),
    padding: EdgeInsets.only(left: 5, right: 5),
    color: color ?? colorScheme.onError,
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
