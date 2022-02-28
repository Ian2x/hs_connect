import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/comment.dart';
import 'package:hs_connect/models/group.dart';

import 'package:hs_connect/shared/widgets/picPickerButton.dart';

typedef VoidFunction = void Function();

typedef VoidGroupParamFunction = void Function (Group?);

typedef VoidDocParamFunction = void Function (DocumentReference?);

typedef VoidFileParamFunction = void Function (File?);

typedef VoidPollDataParamFunction = void Function (int, String);

typedef VoidDocSnapParamFunction = void Function (DocumentSnapshot);

typedef VoidBoolParamFunction = void Function(bool);

typedef VoidOptionalCommentParamFunction = void Function (Comment?);

typedef VoidIntParamFunction = void Function(int);


InputDecoration commentReplyInputDecoration({required VoidFunction onPressed, required bool isReply, required bool isFocused, required BuildContext context, required bool hasText, required Color activeColor}) {
  final colorScheme = Theme.of(context).colorScheme;


  return InputDecoration(
    fillColor: colorScheme.surface,
    filled: true,
    hintText: isReply != false ? "Reply..." : "Comment...",
    hintStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: colorScheme.primary),
    labelStyle: Theme.of(context).textTheme.bodyText1,
    contentPadding: EdgeInsets.fromLTRB(20, 14, 0, 14),
    border: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(25.7),
      borderSide: new BorderSide(width: 3, color: colorScheme.background),
    ),
    enabledBorder: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3, color: colorScheme.background)),
    focusedBorder: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3, color: colorScheme.background)),
    suffixIcon: isFocused ? Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      IconButton(
          icon: Icon(Icons.send),
          color: hasText? activeColor : colorScheme.primary,
          iconSize: 16,
          padding: EdgeInsets.only(left: 5, right: 15),
          splashColor: Colors.transparent,
          onPressed: onPressed,
          constraints: BoxConstraints()),
    ]) : null,
  );
}

InputDecoration messageInputDecoration({required VoidFunction onPressed, required Function setPic, required BuildContext context, required bool hasText, required bool hasImage, required Color activeColor}) {


  final colorScheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: 'Message...',
    fillColor: colorScheme.surface,
    filled: true,
    hintStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: colorScheme.primary),
    labelStyle: Theme.of(context).textTheme.bodyText1,
    contentPadding: EdgeInsets.fromLTRB(20, 14, 0, 14),
    border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3, color: colorScheme.background),
    ),
    enabledBorder: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3, color: colorScheme.background)),
    focusedBorder: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7),
        borderSide: new BorderSide(width: 3, color: colorScheme.background)),
    suffixIcon: Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      picPickerButton(setPic: setPic, iconSize: 16, context: context, maxWidth: 1200, maxHeight: 1200, color: hasImage ? activeColor : colorScheme.primary),
      IconButton(
          icon: Icon(Icons.send),
          color: hasText ? activeColor : colorScheme.primary,
          iconSize: 16,
          padding: EdgeInsets.only(left: 5, right: 15),
          splashColor: Colors.transparent,
          onPressed: onPressed,
          constraints: BoxConstraints()),
    ]),
  );
}
