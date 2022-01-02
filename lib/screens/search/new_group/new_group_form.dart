import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/input_decorations.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


class AccessOption {
  AccessOption();
}

class NewGroupForm extends StatefulWidget {
  const NewGroupForm({Key? key}) : super(key: key);

  @override
  _NewGroupFormState createState() => _NewGroupFormState();
}

class _NewGroupFormState extends State<NewGroupForm> {
  final _formKey = GlobalKey<FormState>();

  void handleError(err) {
    if (mounted) {
      setState(() {
        error = 'ERROR: something went wrong, possibly with username to email conversion';
      });
    }
  }

  void handleValue(val) {
    loading = false;
    Navigator.pop(context);
  }

  // form values
  String _name = '';
  String _description = '';
  AccessRestriction? _accessRestriction = null;
  String error = '';
  bool loading = false;

  String? newFileURL;
  File? newFile;

  ImageStorage _images = ImageStorage();


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      // Don't expect to be here, but just in case
      return Loading();
    } else {

      final List<AccessRestriction> accessOptions = [
        AccessRestriction(restrictionType: 'domain', restriction: userData.domain),
      ];
      if(userData.county!=null) {
        accessOptions.add(AccessRestriction(restrictionType: 'county', restriction: userData.county!));
      }
      if(userData.state!=null) {
        accessOptions.add(AccessRestriction(restrictionType: 'state', restriction: userData.state!));
      }
      if(userData.country!=null) {
        accessOptions.add(AccessRestriction(restrictionType: 'country', restriction: userData.country!));
      }

      return SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                'Form a new group',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              Text('Group name'),
              TextFormField(
                initialValue: '',
                decoration: textInputDecoration,
                validator: (val) {
                  if (val == null) return 'Error: null value';
                  if (val.isEmpty)
                    return 'Group name is required';
                  else
                    return null;
                },
                onChanged: (val) {
                  if (mounted) {
                    setState(() => _name = val);
                  }
                },
              ),
              SizedBox(height: 20.0),
              DropdownButtonFormField<AccessRestriction>(
                decoration: textInputDecoration,
                value: _accessRestriction,
                items: accessOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option.restriction),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Must select access restrictions' : null,
                onChanged: (val) {
                  if (mounted) {
                    setState(() => _accessRestriction = val!);
                  }
                },
              ),
              FloatingActionButton(
                onPressed: () async {
                  try {
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      if (mounted) {
                        setState(() {
                          newFile = File(pickedFile.path);
                        });
                      }
                    } else {
                      if (mounted) {
                        setState(() {
                          newFile = null;
                        });
                      }
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                heroTag: 'image0',
                tooltip: 'Pick Image from gallery',
                child: const Icon(Icons.photo),
              ),
              newFile != null
                  ? Semantics(
                label: 'new_profile_pic_picked_image',
                child: kIsWeb ? Image.network(newFile!.path) : Image.file(File(newFile!.path)),
              )
                  : Container(),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.pink[400],
                  ),
                  onPressed: () async {

                    if (newFile != null) {
                      // upload newFile
                      final downloadURL = await _images.uploadImage(file: newFile!);
                      if (mounted) {
                        setState(() {
                          newFileURL = downloadURL;
                        });
                      }
                    }

                    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                      if (mounted) {
                        setState(() => loading = true);
                      }
                      await GroupsDatabaseService().newGroup(
                        accessRestrictions: _accessRestriction!,
                        name: _name,
                        creatorRef: userData.userRef,
                        image: newFileURL,
                        description: _description,
                        onValue: handleValue,
                        onError: handleError,
                      );


                    }


                  },
                  child: Text(
                    'Make group',
                    style: TextStyle(color: Colors.white),
                  )),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              )
            ],
          ),
        ),
      );
    }

    return Container();
  }
}
