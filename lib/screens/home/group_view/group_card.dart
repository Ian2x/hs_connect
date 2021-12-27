import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/user_data_database.dart';

class GroupCard extends StatefulWidget {
  final DocumentReference groupRef;
  final DocumentReference? userRef;
  final String name;
  final String? image;
  final String? description;
  final AccessRestriction accessRestrictions;
  final DocumentReference currUserRef;
  final int numMembers;
  final List<DocumentReference> moderatorRefs;

  GroupCard(
      {Key? key,
        required this.groupRef,
        this.userRef,
        required this.name,
        required this.description,
        this.image,
        required this.accessRestrictions,
        required this.currUserRef,
        required this.numMembers,
        required this.moderatorRefs,
      })
      : super(key: key);

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  UserDataDatabaseService _userInfoDatabaseService = UserDataDatabaseService();

  GroupsDatabaseService _groups = GroupsDatabaseService();

  PostsDatabaseService _posts = PostsDatabaseService();

  String username = '<Loading user name...>';
  String groupName = '<Loading group name...>';

  @override
  void initState() {
    // find username for userId
    // _userInfoDatabaseService.userId = widget.userId;
    getUsername();
    groupName = widget.name;
    super.initState();
    print("a group image:");
    print(widget.image);
  }

  void getUsername() async {
    if (widget.userRef!=null) {
      final UserData? fetchUsername = await _userInfoDatabaseService.getUserData(userRef: widget.userRef!);
      setState(() {
        username = fetchUsername != null ? fetchUsername.displayedName : '<Failed to retrieve user name>';
      });
    } else {
      setState(() {
        username = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: Text(widget.name),
              subtitle: username!='' ? Text(username+' made the group '+groupName) : Text('(domain group)'),
              onTap: () { },
            ),
        ]));
  }
}
