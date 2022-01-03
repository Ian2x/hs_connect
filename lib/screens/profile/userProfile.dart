import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/authenticate/authenticate.dart';
import 'package:hs_connect/screens/profile/profileForm.dart';
import 'package:hs_connect/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/shared/widgets/navigationBar.dart';

class userProfile extends StatelessWidget {
  final profileId;

  userProfile({Key? key, required this.profileId}) : super(key: key);

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    if (_auth.user == null) {
      return Authenticate();
    }

    final user = Provider.of<User?>(context);
    final userData = Provider.of<UserData?>(context);

    // unnecessary?
    if (user == null) {
      return Authenticate();
    }

    if (user != null && user.uid == profileId && userData != null) {
      return Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text('Your Profile'),
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.person),
              label: Text('Logout'),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
        ),
        body: Container(
          child: ProfileForm(
            currDisplayName: userData.displayedName,
            currImageURL: userData.profileImage,
          ),
        ),
        bottomNavigationBar: navigationBar(
          currentIndex: 3,
        ),
      );
    } else {}
    return Container(child: Text('someone else'));
  }
}
