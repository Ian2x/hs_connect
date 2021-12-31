import 'package:flutter/material.dart';
import 'package:hs_connect/shared/widgets/my_pic_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
          PicPickerButton(setPic: setPic),
          IconButton(
              icon: Icon(Icons.send),
              iconSize: 12.0,
              onPressed: onPressed
          ),
        ]),
  );
}