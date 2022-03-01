import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/messages_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

import 'package:hs_connect/shared/widgets/deletableImage.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class MessagesForm extends StatefulWidget {
  final DocumentReference otherUserRef;
  final VoidFunction onUpdateLastMessage;
  final VoidFunction onUpdateLastViewed;

  const MessagesForm(
      {Key? key, required this.otherUserRef, required this.onUpdateLastMessage, required this.onUpdateLastViewed})
      : super(key: key);

  @override
  _MessagesFormState createState() => _MessagesFormState();
}

class _MessagesFormState extends State<MessagesForm> {
  final imageBorderRadius = BorderRadius.circular(0);
  final textController = TextEditingController();

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
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    if (userData == null) {
      return Loading();
    }

    MessagesDatabaseService _messages = MessagesDatabaseService(currUserRef: userData.userRef);

    return Container(
      padding: EdgeInsets.fromLTRB(
          10, 10, 10, MediaQuery.of(context).padding.bottom > 10 ? MediaQuery.of(context).padding.bottom : 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.background,
            offset: Offset(0.0, -1.0), //(x,y)
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
        newFile != null && !loading
            ? Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Semantics(
                    label: 'new_message_image',
                    child: DeletableImage(
                      image: Image.file(File(newFile!.path), fit: BoxFit.contain),
                      onDelete: () => setPic(null),
                      maxHeight: 150,
                      containerWidth: MediaQuery.of(context).size.width / 2,
                    )),
              )
            : Container(),
        TextField(
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            style: Theme.of(context).textTheme.subtitle1,
            controller: textController,
            decoration: messageInputDecoration(
                context: context,
                setPic: setPic,
                activeColor: userData.domainColor ?? colorScheme.secondary,
                onPressed: () async {
                    if (mounted) {
                      setState(() => loading = true);
                    }
                    textController.clear();
                    if (newFile != null) {
                      // upload newFile
                      final downloadURL = await _images.uploadImage(file: newFile!);

                      await _messages.newMessage(
                          receiverRef: widget.otherUserRef,
                          text: downloadURL,
                          isMedia: true,
                          senderRef: userData.userRef);
                    }
                    if (_message != null && _message != '') {
                      await _messages.newMessage(
                          receiverRef: widget.otherUserRef,
                          text: _message!,
                          isMedia: false,
                          senderRef: userData.userRef);
                    }
                    if (mounted) {
                      setState(() {
                        loading = false;
                        newFile = null;
                        _message = null;
                      });
                    }
                    widget.onUpdateLastMessage();
                    widget.onUpdateLastViewed();
                },
                hasText: (_message != null && _message != '') || newFile != null,
                hasImage: newFile != null),
            onChanged: (val) {
              if (mounted) {
                setState(() => _message = val);
              }
            })
      ]),
    );
  }
}
