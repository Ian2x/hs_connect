import 'package:flutter/material.dart';
import 'package:hs_connect/screens/profile/profileForm.dart';
import 'package:hs_connect/services/auth.dart';

class ProfileFormPage extends StatelessWidget {
  final ProfileForm profileForm;

  ProfileFormPage({Key? key, required this.profileForm}) : super(key: key);

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: profileForm,
    );
  }
}
