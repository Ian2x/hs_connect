

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/shared/widgets/picPickerButton.dart';

import 'constants.dart';

// used for authentication and profile form
InputDecoration textInputDecoration({required double hp, required double wp, }) {
  return InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2*wp)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink, width: 2*wp)),
  );
}

typedef VoidFunction = void Function();

typedef VoidGroupParamFunction = void Function (Group?);

typedef VoidDocParamFunction = void Function (DocumentReference?);

typedef VoidFileParamFunction = void Function (File?);

typedef VoidPollDataParamFunction = void Function (int, String);

typedef VoidDocSnapParamFunction = void Function (DocumentSnapshot);


InputDecoration commentReplyInputDecoration({required VoidFunction onPressed, required Function setPic, required bool isReply, required bool isFocused, required double hp, required double wp}) {
  return InputDecoration(
    fillColor: ThemeColor.white, filled: true,
    hintText: isReply != false ? "Reply..." : "Comment...",
    hintStyle: ThemeText.roboto(fontSize: 16*hp, color: ThemeColor.lightMediumGrey),
    labelStyle: ThemeText.roboto(fontSize: 16*hp, color: ThemeColor.lightMediumGrey),
    contentPadding: EdgeInsets.fromLTRB(20*wp, 14*hp, 0*wp, 14*hp),
    border: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(25.7*hp),
      borderSide: new BorderSide(width: 3*wp, color: ThemeColor.lightGrey),
    ),
    enabledBorder: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7*hp),
        borderSide: new BorderSide(width: 3*wp, color: ThemeColor.lightGrey)),
    focusedBorder: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7*hp),
        borderSide: new BorderSide(width: 3*wp, color: ThemeColor.lightGrey)),
    suffixIcon: isFocused ? Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      picPickerButton(setPic: setPic, iconSize: 16*hp),
      IconButton(
          icon: Icon(Icons.send),
          color: ThemeColor.lightMediumGrey,
          iconSize: 16*hp,
          padding: EdgeInsets.only(left: 5*wp, right: 15*wp),
          splashColor: Colors.transparent,
          onPressed: onPressed,
          constraints: BoxConstraints()),
    ]) : null,
  );
}

InputDecoration messageInputDecoration({required VoidFunction onPressed, required Function setPic, required double hp, required double wp}) {
  return InputDecoration(
    hintText: 'Message...',
    fillColor: ThemeColor.white,
    filled: true,
    hintStyle: ThemeText.roboto(fontSize: 16*hp, color: ThemeColor.lightMediumGrey),
    labelStyle: ThemeText.roboto(fontSize: 16*hp, color: ThemeColor.lightMediumGrey),
    contentPadding: EdgeInsets.fromLTRB(20*wp, 14*hp, 0*wp, 14*hp),
    border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7*hp),
        borderSide: new BorderSide(width: 3*wp, color: ThemeColor.lightGrey),
    ),
    enabledBorder: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7*hp),
        borderSide: new BorderSide(width: 3*wp, color: ThemeColor.lightGrey)),
    focusedBorder: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7*hp),
        borderSide: new BorderSide(width: 3*wp, color: ThemeColor.lightGrey)),
    suffixIcon: Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      picPickerButton(setPic: setPic, iconSize: 16*hp),
      IconButton(
          icon: Icon(Icons.send),
          color: ThemeColor.lightMediumGrey,
          iconSize: 16*hp,
          padding: EdgeInsets.only(left: 5*wp, right: 15*wp),
          splashColor: Colors.transparent,
          onPressed: onPressed,
          constraints: BoxConstraints()),
    ]),
  );
}
