import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/profile/profile_form.dart';
import 'package:hs_connect/services/userInfo_database.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  final profileId;

  const Profile({Key? key, required this.profileId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData?>(context);

    if (user.uid == profileId && userData!=null) {
      return Scaffold(
            backgroundColor: Colors.brown[50],
            appBar: AppBar(
              title: Text('Your Profile'),
              backgroundColor: Colors.brown[400],
              elevation: 0.0,
            ),
            body: Container(
              child: ProfileForm(currDisplayName: userData.displayedName, currImageURL: userData.imageURL,),
            ),
          );
    }
    return Container(child: Text('someone else'));
  }
}
