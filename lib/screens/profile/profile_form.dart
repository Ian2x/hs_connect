import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/shared/pic_picker.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key, required this.currDisplayName, required this.currImageURL}) : super(key: key);

  final String currDisplayName;
  final String? currImageURL;

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  // form values
  String? _displayedName;
  String? _initialImageURL;
  String error = '';
  bool loading = false;

  ImageStorage _images = ImageStorage();

  String? newFileURL;
  File? newFile;

  @override
  void initState() {
    _displayedName = widget.currDisplayName;
    _initialImageURL = widget.currImageURL;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData?>(context);

    void handleError(err) {
      setState(() {
        error =
            'ERROR: something went wrong, possibly with username to email conversion';
      });
    }

    void handleValue(val) {
      setState(() => loading = false);
      Navigator.pop(context);
    }

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    } else {
      return loading
          ? Loading()
          : Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            Text(
              'Update your profile.',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              initialValue: userData.displayedName,
              decoration: textInputDecoration,
              validator: (val) {
                if (val == null) return 'Error: null value';
                if (val.isEmpty)
                  return 'Please enter a display name';
                else
                  return null;
              },
              onChanged: (val) =>
                  setState(() => _displayedName = val),
            ),
            FloatingActionButton(
              onPressed: () async {
                try {
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      newFile = File(pickedFile.path);
                    });
                  } else {
                    setState(() {
                      newFile = null;
                    });
                  }
                } catch (e) {
                  print(e);
                }
              },
              heroTag: 'image0',
              tooltip: 'Pick Image from gallery',
              child: const Icon(Icons.photo),
            ),
            newFile != null ?
              Semantics(
                label: 'new_profile_pic_picked_image',
                child: kIsWeb ? Image.network(newFile!.path) : Image.file(File(newFile!.path)),
              )
            :
              _initialImageURL != null ?
                Semantics(
                  label: 'initial_profile_pic_image',
                  child: Image.network(_initialImageURL!),
                )
              :
                Container(),


            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink[400],
                ),
                onPressed: () async {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {

                    setState(() => loading = true);

                    if (newFile!=null) {
                      // upload newFile
                      final downloadURL = await _images.uploadProfilePic(file: newFile!, oldImageURL: _initialImageURL);
                      setState(() {
                        newFileURL = downloadURL;
                      });
                    }

                    await UserInfoDatabaseService(userId: userData.userRef.id)
                        .updateProfile(
                      displayedName: _displayedName ?? userData.displayedName,
                      imageURL: newFileURL, // _initialImageURL ?? userData.imageURL,
                      onValue: handleValue,
                      onError: handleError,
                    );
                  }
                },
                child: Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                )),
            SizedBox(height: 12.0),
            Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 14.0),
            ),
          ],
        ),
      );
    }
  }
}
