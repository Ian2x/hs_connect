

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/shared/widgets/picPickerButton.dart';

import 'constants.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2.0)),
  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink, width: 2.0)),
);

typedef VoidFunction = void Function();

typedef VoidGroupParamFunction = void Function (Group?);

typedef VoidDocParamFunction = void Function (DocumentReference?);

typedef VoidFileParamFunction = void Function (File?);

InputDecoration commentReplyInputDecoration({required VoidFunction onPressed, required Function setPic, required bool isReply}) {
  return InputDecoration(

    fillColor: ThemeColor.white, filled: true,
    hintText: isReply != false ? "Reply..." : "Comment...",
    hintStyle: ThemeText.roboto(fontSize: 16, color: ThemeColor.lightMediumGrey),
    labelStyle: ThemeText.roboto(fontSize: 16, color: ThemeColor.lightMediumGrey),
    contentPadding: EdgeInsets.fromLTRB(20, 14, 0, 14),
    border: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(25.7),
      borderSide: new BorderSide(width: 3.0, color: ThemeColor.lightGrey),
    ),
    enabledBorder: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3.0, color: ThemeColor.lightGrey)),
    focusedBorder: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3.0, color: ThemeColor.lightGrey)),
    suffixIcon: Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      picPickerButton(setPic: setPic, iconSize: 16.0),
      IconButton(
          icon: Icon(Icons.send),
          color: ThemeColor.lightMediumGrey,
          iconSize: 16.0,
          padding: EdgeInsets.only(left: 5, right: 15),
          splashColor: Colors.transparent,
          onPressed: onPressed,
          constraints: BoxConstraints()),
    ]),
  );
}

InputDecoration messageInputDecoration({required VoidFunction onPressed, required Function setPic, required String hintText}) {
  return InputDecoration(
    hintText: hintText,
    fillColor: ThemeColor.white,
    filled: true,
    hintStyle: ThemeText.roboto(fontSize: 16, color: ThemeColor.lightMediumGrey),
    labelStyle: ThemeText.roboto(fontSize: 16, color: ThemeColor.lightMediumGrey),
    contentPadding: EdgeInsets.fromLTRB(20, 14, 0, 14),
    border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3.0, color: ThemeColor.lightGrey),
    ),
    enabledBorder: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3.0, color: ThemeColor.lightGrey)),
    focusedBorder: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3.0, color: ThemeColor.lightGrey)),
    suffixIcon: Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      picPickerButton(setPic: setPic, iconSize: 16.0),
      IconButton(
          icon: Icon(Icons.send),
          color: ThemeColor.lightMediumGrey,
          iconSize: 16.0,
          padding: EdgeInsets.only(left: 5, right: 15),
          splashColor: Colors.transparent,
          onPressed: onPressed,
          constraints: BoxConstraints()),
    ]),
  );
}
