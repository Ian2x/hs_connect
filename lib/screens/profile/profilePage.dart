import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileBody.dart';
import 'package:hs_connect/screens/profile/settings/settingsPage.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/widgets/myNavigationBar.dart';
import 'package:hs_connect/shared/widgets/thicker_icons.dart';

class ProfilePage extends StatelessWidget {
  final UserData currUserData;

  ProfilePage({Key? key, required this.currUserData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: colorScheme.surface,
          actions: [
            IconButton(
                icon: Icon(Thicker.settings_1, color: colorScheme.primaryVariant),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => pixelProvider(context,
                              child: SettingsPage(
                                initialIsLightTheme: Theme.of(context).brightness == Brightness.light,
                                currUserData: currUserData,
                              ))));
                })
          ],
          elevation: 0),
      backgroundColor: colorScheme.surface,
      body: ProfileBody(
        currUserData: currUserData,
      ),
      bottomNavigationBar: MyNavigationBar(
        currentIndex: 2,
        currUserData: currUserData,
      ),
    );
  }
}
