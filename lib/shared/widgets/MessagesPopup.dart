import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessagesPopup extends StatefulWidget {
  final DocumentReference profileRef;
  final DocumentReference currUserRef;

  const MessagesPopup({Key? key, required this.profileRef, required this.currUserRef}) : super(key: key);

  @override
  _MessagesPopupState createState() => _MessagesPopupState();
}

class _MessagesPopupState extends State<MessagesPopup> {

  final _formKey = GlobalKey<FormState>();

  // form values
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
