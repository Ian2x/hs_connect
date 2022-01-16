import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/circleFromGroup.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

import 'MessagesPage.dart';

class AllMessagesPage extends StatefulWidget {
  final UserData userData;
  const AllMessagesPage({Key? key, required this.userData}) : super(key: key);

  @override
  _AllMessagesPageState createState() => _AllMessagesPageState();
}

class _AllMessagesPageState extends State<AllMessagesPage> {

  List<UserMessage>? UMs;
  List<UserData>? otherUsers;
  List<Widget>? groupCirclesForOtherUsers;

  @override
  void initState() {
    List<UserMessage> tempUMs = widget.userData.userMessages;
    // sorted by latest first
    tempUMs.sort((a, b) => b.lastMessage.compareTo(a.lastMessage));
    if (mounted) {
      setState(() {
        UMs = tempUMs;
      });
    }
    fetchUsers(tempUMs);
    super.initState();
  }
  
  Future _fetchUsersHelper(DocumentReference otherUserRef, int index, List<UserData?> results) async {
    results[index] = await userDataFromSnapshot(await otherUserRef.get(), otherUserRef);
  }
  
  Future fetchUsers(List<UserMessage> UMs) async {
    List<UserData?> tempOtherUsers = List.filled(UMs.length, null);
    await Future.wait([for (int i=0; i<UMs.length; i++) _fetchUsersHelper(UMs[i].otherUserRef, i, tempOtherUsers)]);
    List<UserData> tempTempOtherUsers = [];
    for (int i=0; i<tempOtherUsers.length; i++) {
      if(tempOtherUsers[i]!=null) tempTempOtherUsers.add(tempOtherUsers[i]!);
    }
    if(mounted) {
      setState(() {
        otherUsers = tempTempOtherUsers;
      });
    }
    fetchUserGroups(tempTempOtherUsers);
  }

  Future fetchUserGroups(List<UserData> LUD) async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.userData.userRef);
    List<Widget> tempGroupCirclesForOtherUsers = [];
    final CollectionReference groupsCollection = FirebaseFirestore.instance.collection(C.groups);
    final groups = await _groups.getGroups(groupsRefs: LUD.map((UD) => groupsCollection.doc(UD.domain)).toList());
    for (Group? group in groups) {
      tempGroupCirclesForOtherUsers.add(circleFromGroup(group: group, circleSize: 35));
    }
    if (mounted) {
      setState(() {
        groupCirclesForOtherUsers = tempGroupCirclesForOtherUsers;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData?>(context);

    if (userData == null || UMs == null || otherUsers == null || groupCirclesForOtherUsers == null) {
      return Loading();
    }

    if (otherUsers!.length == 0) {
      return Container(
          padding: EdgeInsets.all(10.0),
          child: Text("No messages :/\n\n... maybe try finding a friend", style: ThemeText.titleRegular(color: ThemeColor.black))
      );
    }

    return ListView.builder(
      itemCount: otherUsers!.length,
      physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final otherUser = otherUsers![index];
          return Container(
            padding: EdgeInsets.fromLTRB(4,4,4,4),
            color: ThemeColor.backgroundGrey,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessagesPage(
                          currUserRef: userData.userRef,
                          otherUserRef: otherUser.userRef,
                        )));
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                margin: EdgeInsets.fromLTRB(2.5, 5, 2.5, 2.5),
                elevation: 0,
                color: ThemeColor.white,
                child: Container(padding: EdgeInsets.all(10), child: Text(otherUser.displayedName)),
              ),
            ),
          );
        }
    );
  }
}
