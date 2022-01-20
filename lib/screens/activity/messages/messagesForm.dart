import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/messages_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/widgets/deletableImage.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class MessagesForm extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference otherUserRef;

  const MessagesForm({Key? key, required this.currUserRef, required this.otherUserRef}) : super(key: key);

  @override
  _MessagesFormState createState() => _MessagesFormState();
}

class _MessagesFormState extends State<MessagesForm> {
  final imageBorderRadius = BorderRadius.circular(0);

  final _formKey = GlobalKey<FormState>();

  File? newFile;

  // form values
  String? _message;
  bool loading = false;

  ImageStorage _images = ImageStorage();

  void setPic(File? newFile2) {
    if (mounted) {
      setState(() {
        newFile = newFile2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Loading();
    }

    MessagesDatabaseService _messages = MessagesDatabaseService(currUserRef: userData.userRef);

    return loading
        ? Container()
        : Container(
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                newFile != null
                    ? Semantics(
                        label: 'new_message_image',
                        child: Container(
                          width: 150,
                          height: 150,
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(color: ThemeColor.lightGrey, borderRadius: imageBorderRadius),
                          child: ClipRRect(
                              borderRadius: imageBorderRadius,
                              child: DeletableImage(
                                image: Image.file(File(newFile!.path), fit: BoxFit.scaleDown),
                                onDelete: () => setPic(null),
                                buttonSize: 30.0,
                              )),
                        ))
                    : Container(),
                TextFormField(
                    initialValue: null,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: messageInputDecoration(
                        setPic: setPic,
                        onPressed: () async {
                          if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                            if (mounted) {
                              setState(() => loading = true);
                            }

                            if (newFile != null) {
                              // upload newFile
                              final downloadURL = await _images.uploadImage(file: newFile!);

                              await _messages.newMessage(
                                  receiverRef: widget.otherUserRef,
                                  text: downloadURL,
                                  isMedia: true,
                                  createdAt: Timestamp.now(),
                                  senderRef: userData.userRef);
                            }
                            if (_message != null && _message != '') {
                              await _messages.newMessage(
                                  receiverRef: widget.otherUserRef,
                                  text: _message!,
                                  isMedia: false,
                                  createdAt: Timestamp.now(),
                                  senderRef: userData.userRef);
                            }
                            if (mounted) {
                              setState(() {
                                loading = false; newFile = null;
                              });
                            }
                          }
                        }),
                    onChanged: (val) {
                      if (mounted) {
                        setState(() => _message = val);
                      }
                    })
              ]),
            ),
          );
  }
}
