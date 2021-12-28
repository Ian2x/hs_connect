import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class CommentForm extends StatefulWidget {
  final DocumentReference postRef;

  const CommentForm({Key? key, required this.postRef}) : super(key: key);

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _formKey = GlobalKey<FormState>();

  void handleError(err) {
    setState(() {
      error = 'ERROR: something went wrong :(';
    });
  }

  void handleValue(val) {
    loading = false;
  }

  String? newFileURL;
  File? newFile;

  // form values
  String _text = '';
  String error = '';
  bool loading = false;

  ImageStorage _images = ImageStorage();

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    void setPic(File newFile2) {
      setState(() {
        newFile = newFile2;
      });
    }

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    } else {
      return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              initialValue: '',
              decoration: messageInputDecoration(
                  onPressed: () async {
                    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                      setState(() => loading = true);

                      if (newFile != null) {
                        // upload newFile
                        final downloadURL = await _images.uploadImage(file: newFile!);
                        setState(() {
                          newFileURL = downloadURL;
                        });
                      }

                      await CommentsDatabaseService(userRef: userData.userRef).newComment(
                        postRef: widget.postRef,
                        text: _text,
                        mediaURL: newFileURL,
                        onValue: handleValue,
                        onError: handleError,
                      );
                    }
                  },
                  setPic: setPic),
              validator: (val) {
                if (val == null) return 'Error: null value';
                if (val.isEmpty)
                  return 'Can\'t create an empty comment';
                else
                  return null;
              },
              onChanged: (val) => setState(() => _text = val),
            ),
            newFile != null
                ? Semantics(
                    label: 'new_profile_pic_picked_image',
                    child: kIsWeb ? Image.network(newFile!.path) : Image.file(File(newFile!.path)),
                  )
                : Container(),
            Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 14.0),
            )
          ],
        ),
      );
    }
  }
}
