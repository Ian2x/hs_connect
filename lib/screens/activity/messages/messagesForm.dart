import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/messages_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
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
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    if (userData == null) {
      return Loading();
    }

    MessagesDatabaseService _messages = MessagesDatabaseService(currUserRef: userData.userRef);

    return Container(
      padding: EdgeInsets.fromLTRB(10*wp, 10*hp, 10*wp, MediaQuery.of(context).padding.bottom>10 ? MediaQuery.of(context).padding.bottom : 10*hp),
      color: colorScheme.background,
      child: Form(
             key: _formKey,
             child: Column(crossAxisAlignment: CrossAxisAlignment.end,
             children: <Widget>[
               newFile != null && !loading
                   ? Semantics(
                       label: 'new_message_image',
                       child: Container(
                         width: 150*wp,
                         height: 150*hp,
                         decoration: BoxDecoration(borderRadius: imageBorderRadius),
                         child: DeletableImage(
                           image: Image.file(File(newFile!.path), fit: BoxFit.contain),
                           onDelete: () => setPic(null),
                           height: 144*hp, width: 144*wp,
                         ),
                       ))
                   : Container(),
               TextFormField(
                   autocorrect: true,
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
