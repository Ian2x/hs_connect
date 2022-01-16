import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/widgets/picPickerButton.dart';

import 'constants.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2.0)),
  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink, width: 2.0)),
);

typedef voidFunction = void Function();

typedef voidParamFunction = void Function (DocumentReference?);

InputDecoration commentInputDecoration({required voidFunction onPressed, required Function setPic, required bool isReply}) {
  return InputDecoration(
    fillColor: Colors.white,
    hintText: isReply != false ? "Reply..." : "Comment...",
    filled: true,
    isDense: true,
    contentPadding: EdgeInsets.all(0.0),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.0)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink, width: 1.0)),
    suffixIcon: Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      PicPickerButton(setPic: setPic),
      IconButton(icon: Icon(Icons.send), iconSize: 12.0, onPressed: onPressed),
    ]),
  );
}

InputDecoration messageInputDecoration({required voidFunction onPressed, required Function setPic}) {
  return InputDecoration(
    hintText: "Comment...",
    fillColor: ThemeColor.white,
    filled: true,
    border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3.0, color: ThemeColor.lightGrey)),
    enabledBorder: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3.0, color: ThemeColor.lightGrey)),
    focusedBorder: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3.0, color: ThemeColor.mediumGrey)),
    suffixIcon: Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      PicPickerButton(setPic: setPic),
      IconButton(icon: Icon(Icons.send), iconSize: 12.0, onPressed: onPressed),
    ]),
  );
}
