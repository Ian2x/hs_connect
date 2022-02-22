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
  final DocumentReference currUserRef;
  final DocumentReference otherUserRef;
  final VoidFunction onUpdateLastMessage;
  final VoidFunction onUpdateLastViewed;

  const MessagesForm({Key? key, required this.currUserRef, required this.otherUserRef, required this.onUpdateLastMessage, required this.onUpdateLastViewed}) : super(key: key);

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
    final colorScheme = Theme.of(context).colorScheme;

    if (userData == null) {
      return Loading();
    }

    MessagesDatabaseService _messages = MessagesDatabaseService(currUserRef: userData.userRef);

    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, MediaQuery.of(context).padding.bottom>10 ? MediaQuery.of(context).padding.bottom : 10),
      color: colorScheme.background,
      child: Form(
             key: _formKey,
             child: Column(crossAxisAlignment: CrossAxisAlignment.end,
             children: <Widget>[
               newFile != null && !loading
                   ? Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                     child: Semantics(
                         label: 'new_message_image',
                         child: DeletableImage(
                           image: Image.file(File(newFile!.path), fit: BoxFit.contain),
                           onDelete: () => setPic(null),
                           maxHeight: 150, containerWidth: MediaQuery.of(context).size.width / 2,
                         )),
                   )
                   : Container(),
               TextFormField(
                   autocorrect: true,
                   textCapitalization: TextCapitalization.sentences,
                   initialValue: null,
                   keyboardType: TextInputType.multiline,
                   maxLines: null,
                   style: Theme.of(context).textTheme.subtitle1,
                   decoration: messageInputDecoration(
                       context: context,
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
                           _formKey.currentState?.reset();
                           widget.onUpdateLastMessage();
                           widget.onUpdateLastViewed();
                         }
                       }, hasText: (_message!=null && _message!='') || newFile!=null, hasImage: newFile!=null),
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
