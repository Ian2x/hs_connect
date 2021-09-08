import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/models/group.dart';
import 'package:hs_connect/Backend/models/user_data.dart';
import 'package:hs_connect/Backend/services/groups_database.dart';
import 'package:hs_connect/Backend/shared/constants.dart';
import 'package:hs_connect/Backend/shared/loading.dart';
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
    setState(() {
      error = 'ERROR: something went wrong, possibly with username to email conversion';
    });
  }

  void handleValue(val) {
    loading = false;
    Navigator.pop(context);
  }

  // form values
  String _name = '';
  String _image = '';
  AccessRestriction? _accessRestriction = null;
  String error = '';
  bool loading = false;

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
        AccessRestriction(restrictionType: 'county', restriction: userData.county),
        AccessRestriction(restrictionType: 'state', restriction: userData.state),
        AccessRestriction(restrictionType: 'country', restriction: userData.country),
      ];

      return Form(
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
              onChanged: (val) => setState(() => _name = val),
            ),
            SizedBox(height: 20.0),
            Text('Group image (optional)'),
            TextFormField(
              initialValue: '',
              decoration: textInputDecoration,
              validator: (val) {
                if (val == null) return 'Error: null value';
                else
                  return null;
              },
              onChanged: (val) => setState(() => _image = val),
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
              onChanged: (val) => setState(() => _accessRestriction = val!),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink[400],
                ),
                onPressed: () async {
                  if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    await GroupsDatabaseService().newGroup(
                      accessRestrictions: _accessRestriction!,
                      name: _name,
                      userId: user.uid,
                      image: _image,
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
      );
    }

    return Container();
  }
}
