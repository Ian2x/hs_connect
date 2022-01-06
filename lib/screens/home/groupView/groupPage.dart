import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/commentFeed/commentsFeed.dart';
import 'package:hs_connect/screens/home/postFeed/specificGroupFeed.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/navigationBar.dart';
import 'package:provider/provider.dart';

class GroupPage extends StatefulWidget {
  final DocumentReference currUserRef;
  final DocumentReference groupRef;

  GroupPage({Key? key, required this.groupRef, required this.currUserRef}) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  String groupName= "";
  String? groupImage;
  int groupMemberCount=0;
  String? groupDescription;

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroupData = await _groups.getGroupData(groupRef: widget.groupRef);
    if (mounted) {
      setState(() {
        groupName = fetchGroupData != null ? fetchGroupData.name : '<Failed to retrieve group name>';
        groupMemberCount = fetchGroupData != null ? fetchGroupData.numMembers : 0;
        //groupDesc.
        if (fetchGroupData != null) {
          if (fetchGroupData.description !=null){
            groupDescription = fetchGroupData.description!;} else {groupName= "";}
        } else {groupDescription = '<Failed to retrieve group description>';}
        //groupImage
        if (fetchGroupData != null) {
          if (fetchGroupData.image !=null){
            groupImage = fetchGroupData.image!;} else {groupImage= "";}
        } else {groupImage = '<Failed to retrieve group name>';}
      });
    }
  }

  @override
  void initState() {
    getGroupData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    if (userData == null) {
      return Text("loading");
    }

    return Scaffold(
      backgroundColor: HexColor("FFFFFF"),
      appBar: AppBar(
        title: Text(groupName,
            style: TextStyle(
              color: HexColor('FFFFFF'), //fontFamily)
            )),
        backgroundColor: HexColor("FFFFFF"),
        elevation: 0.0,
      ),
      body:

      SpecificGroupFeed(groupRef: widget.groupRef, currUserRef: userData.userRef,),

      bottomNavigationBar: navigationBar(currentIndex:0),
    );
  }
}
