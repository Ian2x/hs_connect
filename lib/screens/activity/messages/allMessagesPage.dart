import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:intl/intl.dart';

import 'MessagesPage.dart';

class UMUD {
  UserMessage? UM;
  UserData? UD;

  UMUD({required this.UM, required this.UD});
}

class AllMessagesPage extends StatefulWidget {
  final UserData userData;

  const AllMessagesPage({Key? key, required this.userData}) : super(key: key);

  @override
  _AllMessagesPageState createState() => _AllMessagesPageState();
}

class _AllMessagesPageState extends State<AllMessagesPage> {
  List<UserMessage>? UMs;
  List<UserData>? otherUsers;
  List<UMUD> UMUDcache = [];

  @override
  void initState() {
    List<UserMessage> tempUMs = widget.userData.userMessages;
    if (mounted) {
      setState(() {
        for (UserMessage UM in tempUMs) {
          UMUDcache.add(UMUD(UM: UM, UD: null));
        }
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
    await Future.wait([for (int i = 0; i < UMs.length; i++) _fetchUsersHelper(UMs[i].otherUserRef, i, tempOtherUsers)]);
    List<UserData> tempTempOtherUsers = [];
    for (int i = 0; i < tempOtherUsers.length; i++) {
      if (tempOtherUsers[i] != null) tempTempOtherUsers.add(tempOtherUsers[i]!);
    }
    if (mounted) {
      setState(() {
        if (tempTempOtherUsers.length == UMs.length) {
          for (int i = 0; i < tempTempOtherUsers.length; i++) {
            UMUDcache[i].UD = tempTempOtherUsers[i];
          }
          otherUsers = tempTempOtherUsers;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (UMs == null || otherUsers == null) {
      return Loading();
    }

    if (otherUsers!.length == 0) {
      return Container(
          padding: EdgeInsets.only(top: 50),
          alignment: Alignment.topCenter,
          child: Text("No messages :/",
              style: textTheme.headline6?.copyWith(fontWeight: FontWeight.normal)));
    }

    // sorted by latest first
    UMUDcache.sort((UMUD a, UMUD b) => b.UM!.lastMessage.compareTo(a.UM!.lastMessage));
    return ListView.builder(
        itemCount: UMUDcache.length,
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final otherUser = UMUDcache[index].UD!;
          if (widget.userData.blockedUserRefs.contains(otherUser.userRef)) {
            return Container();
          }
          final updateLastMessage = () {
            UMUDcache[index].UM!.lastMessage = Timestamp.now();
          };
          final updateLastViewed = () {
            UMUDcache[index].UM!.lastViewed = Timestamp.now();
          };
          return GestureDetector(
            onTap: () async {
              final _ = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MessagesPage(
                            currUserRef: widget.userData.userRef,
                            otherUserRef: otherUser.userRef,
                            otherUserFundName: otherUser.fundamentalName,
                            onUpdateLastMessage: updateLastMessage,
                            onUpdateLastViewed: updateLastViewed,
                          )));
              if (mounted) {
                setState(() {
                  UMUDcache[index].UM!.lastViewed = Timestamp.now();
                });
              }
            },
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(
                        top: index == 0 ? 4.5 : 2, bottom: index == UMUDcache.length - 1 ? 2.5 : 0),
                    padding: EdgeInsets.fromLTRB(20, 13, 14, 15),
                    color: colorScheme.surface,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      ProfileImage(backgroundColor: otherUser.domainColor, size: 33),
                      SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Text(otherUser.fundamentalName,
                            style: textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(otherUser.fullDomainName != null ? otherUser.fullDomainName! : otherUser.domain,
                            style: textTheme.bodyText2?.copyWith(color: otherUser.domainColor!=null ? otherUser.domainColor! : colorScheme.primary))
                      ]),
                      Flexible(
                          child: Column(children: <Widget>[
                        Row(children: <Widget>[
                          Spacer(),
                          isToday(UMUDcache[index].UM!.lastMessage.toDate())
                              ? Text(DateFormat.jm().format(UMUDcache[index].UM!.lastMessage.toDate()),
                                  style: textTheme.bodyText2?.copyWith(color: colorScheme.primary))
                              : Text(DateFormat.yMd().format(UMUDcache[index].UM!.lastMessage.toDate()),
                                  style: textTheme.bodyText2?.copyWith(color: colorScheme.primary))
                        ])
                      ]))
                    ])),
                (UMUDcache[index].UM!.lastViewed == null ||
                        UMUDcache[index].UM!.lastViewed!.compareTo(UMUDcache[index].UM!.lastMessage) < 0)
                    ? Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.only(
                            top: index == 0 ? 4.5 : 2,
                            left: 6,
                            bottom: index == UMUDcache.length - 1 ? 2.5 : 0),
                        decoration: BoxDecoration(
                          color: (UMUDcache[index].UM!.lastViewed == null ||
                              UMUDcache[index].UM!.lastViewed!.compareTo(UMUDcache[index].UM!.lastMessage) < 0)
                              ? colorScheme.secondary : Colors.green,
                          shape: BoxShape.circle,
                        ),
                )
                    : Container()
              ],
            ),
          );
        });
  }
}
