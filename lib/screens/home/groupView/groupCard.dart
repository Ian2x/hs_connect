import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/user_data_database.dart';

class GroupCard extends StatefulWidget {
  final Group group;
  final DocumentReference currUserRef;

  GroupCard({
    Key? key,
    required this.group, required this.currUserRef,
  }) : super(key: key);

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {

  String username = '<Loading user name...>';
  String groupName = '<Loading group name...>';

  @override
  void initState() {
    getUsername();
    groupName = widget.group.name;
    super.initState();
  }

  void getUsername() async {
    if (widget.group.creatorRef != null) {
      UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService(currUserRef: widget.currUserRef);
      final UserData? fetchUsername = await _userInfoDatabaseService.getUserData(userRef: widget.group.creatorRef!);
      if (mounted) {
        setState(() {
          username = fetchUsername != null ? fetchUsername.displayedName : '<Failed to retrieve user name>';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          username = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      ListTile(
        title: Text(widget.group.name),
        subtitle: username != '' ? Text(username + ' made the group ' + groupName) : Text('(domain group)'),
        onTap: () {},
      ),
    ]));
  }
}
