import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

IconButton PicPickerButton({required Function setPic, iconSize=12.0, maxHeight=400.0, maxWidth=400.0, imageQuality=100}) {
  return IconButton(
    icon: Icon(Icons.photo),
    iconSize: iconSize,
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