import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/widgets/picPickerButton.dart';
import 'package:provider/provider.dart';

typedef VoidFunction = void Function();

typedef VoidGroupParamFunction = void Function (Group?);

typedef VoidDocParamFunction = void Function (DocumentReference?);

typedef VoidFileParamFunction = void Function (File?);

typedef VoidPollDataParamFunction = void Function (int, String);

typedef VoidDocSnapParamFunction = void Function (DocumentSnapshot);

typedef VoidBoolParamFunction = void Function(bool);


InputDecoration commentReplyInputDecoration({required VoidFunction onPressed, required bool isReply, required bool isFocused, required BuildContext context}) {
  final colorScheme = Theme.of(context).colorScheme;
  final hp = Provider.of<HeightPixel>(context).value;
  final wp = Provider.of<WidthPixel>(context).value;
  return InputDecoration(
    fillColor: colorScheme.surface,
    filled: true,
    hintText: isReply != false ? "Reply..." : "Comment...",
    hintStyle: Theme.of(context).textTheme.bodyText1,
    labelStyle: Theme.of(context).textTheme.bodyText1,
    contentPadding: EdgeInsets.fromLTRB(20*wp, 14*hp, 0*wp, 14*hp),
    border: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(25.7*hp),
      borderSide: new BorderSide(width: 3*wp, color: colorScheme.background),
    ),
    enabledBorder: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7*hp),
        borderSide: new BorderSide(width: 3*wp, color: colorScheme.background)),
    focusedBorder: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7*hp),
        borderSide: new BorderSide(width: 3*wp, color: colorScheme.background)),
    suffixIcon: isFocused ? Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      IconButton(
          icon: Icon(Icons.send),
          color: colorScheme.onError,
          iconSize: 16*hp,
          padding: EdgeInsets.only(left: 5*wp, right: 15*wp),
          splashColor: Colors.transparent,
          onPressed: onPressed,
          constraints: BoxConstraints()),
    ]) : null,
  );
}

InputDecoration messageInputDecoration({required VoidFunction onPressed, required Function setPic, required BuildContext context}) {
  final hp = Provider.of<HeightPixel>(context).value;
  final wp = Provider.of<WidthPixel>(context).value;
  final colorScheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: 'Message...',
    fillColor: colorScheme.surface,
    filled: true,
    hintStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: colorScheme.primary),
    labelStyle: Theme.of(context).textTheme.bodyText1,
    contentPadding: EdgeInsets.fromLTRB(20*wp, 14*hp, 0*wp, 14*hp),
    border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7*hp),
        borderSide: new BorderSide(width: 3*wp, color: colorScheme.background),
    ),
    enabledBorder: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7*hp),
        borderSide: new BorderSide(width: 3*wp, color: colorScheme.background)),
    focusedBorder: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.7*hp),
        borderSide: new BorderSide(width: 3*wp, color: colorScheme.background)),
    suffixIcon: Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: <Widget>[
      picPickerButton(setPic: setPic, iconSize: 16*hp, context: context, maxWidth: 400*hp, maxHeight: 400*hp),
      IconButton(
          icon: Icon(Icons.send),
          color: colorScheme.onError,
          iconSize: 16*hp,
          padding: EdgeInsets.only(left: 5*wp, right: 15*wp),
          splashColor: Colors.transparent,
          onPressed: onPressed,
          constraints: BoxConstraints()),
    ]),
  );
}
