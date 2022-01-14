import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/shared/constants.dart';
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

  @override
  void initState() {
    // TODO: implement initState
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
    results[index] = userDataFromSnapshot(await otherUserRef.get(), otherUserRef);
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
  }

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData?>(context);

    if (userData == null || UMs == null || otherUsers == null) {
      return Loading();
    }

    return ListView.builder(
      itemCount: otherUsers!.length,
      physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final otherUser = otherUsers![index];
          return Container(
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
                child: Container(padding: EdgeInsets.all(10), child: Text(otherUser.displayedName)),
              ),
            ),
          );
        }
    );
  }
}
