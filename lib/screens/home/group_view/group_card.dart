import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/post_view/delete_post.dart';
import 'package:hs_connect/screens/home/post_view/post_page.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/userInfo_database.dart';

class GroupCard extends StatefulWidget {
  final String groupId;
  final String? userId;
  final String name;
  final String? image;
  final AccessRestriction accessRestrictions;
  final String currUserId;

  GroupCard(
      {Key? key,
        required this.groupId,
        this.userId,
        required this.name,
        this.image,
        required this.accessRestrictions,
        required this.currUserId})
      : super(key: key);

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  UserInfoDatabaseService _userInfoDatabaseService = UserInfoDatabaseService();

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
    if (widget.userId!=null) {
      final UserData? fetchUsername = await _userInfoDatabaseService.getUserData(userId: widget.userId!);
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
