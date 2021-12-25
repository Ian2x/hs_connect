import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Calculate trending by activity within past 2 days
const daysTrending = 2;

const double profilePicWidth = 400;
const double profilePicHeight = 400;

const double groupPicWidth = 400;
const double groupPicHeight = 400;


const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2.0)),
  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink, width: 2.0)),
);

typedef voidFunction = void Function();

InputDecoration messageInputDecoration({required voidFunction onPressed, required Function setPic}) {
  return InputDecoration(
    fillColor: Colors.white,
    filled: true,
    isDense: true,
    contentPadding: EdgeInsets.all(0.0),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.0)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink, width: 1.0)),
    suffixIcon: Row(
      mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
      IconButton(
        icon: Icon(Icons.photo),
        iconSize: 12.0,
        onPressed: () async {
          try {
            final pickedFile = await ImagePicker().pickImage(
              source: ImageSource.gallery,
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
      ),
      IconButton(
        icon: Icon(Icons.send),
        iconSize: 12.0,
        onPressed: onPressed
      ),
    ]),
  );
}
