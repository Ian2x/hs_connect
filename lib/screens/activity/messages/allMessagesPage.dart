import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  List<UMUD> cache = [];

  @override
  void initState() {
    List<UserMessage> tempUMs = widget.userData.userMessages;
    // sorted by latest first
    // tempUMs.sort((a, b) => b.lastMessage.compareTo(a.lastMessage));
    if (mounted) {
      setState(() {
        for (UserMessage UM in tempUMs) {
          cache.add(UMUD(UM: UM, UD: null));
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
            cache[i].UD = tempTempOtherUsers[i];
          }
          otherUsers = tempTempOtherUsers;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null || UMs == null || otherUsers == null) {
      return Loading();
    }

    if (otherUsers!.length == 0) {
      return Container(
          padding: EdgeInsets.all(10.0),
          child: Text("No messages :/\n\n... maybe try finding a friend",
              style: ThemeText.titleRegular(color: ThemeColor.black)));
    }

    // sorted by latest first
    cache.sort((UMUD a, UMUD b) => b.UM!.lastMessage.compareTo(a.UM!.lastMessage));

    return ListView.builder(
        itemCount: cache.length,
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final otherUser = cache[index].UD!;
          final updateLastMessage = () {
            cache[index].UM!.lastMessage = Timestamp.now();
          };
          final updateLastViewed = () {
            cache[index].UM!.lastViewed = Timestamp.now();
          };
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MessagesPage(
                            currUserRef: userData.userRef,
                            otherUserRef: otherUser.userRef,
                            onUpdateLastMessage: updateLastMessage,
                            onUpdateLastViewed: updateLastViewed,
                          )));
            },
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(top: index == 0 ? 4.5 : 2),
                    padding: EdgeInsets.fromLTRB(20, 14, 14, 16),
                    color: ThemeColor.white,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      Container(
                          width: 40,
                          height: 40,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(fit: BoxFit.fill, image: otherUser.profileImage.image))),
                      SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Text(otherUser.displayedName,
                            style:
                                ThemeText.inter(fontSize: 15, color: ThemeColor.darkGrey, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(otherUser.fullDomainName != null ? otherUser.fullDomainName! : otherUser.domain,
                            style: ThemeText.inter(fontSize: 15, color: ThemeColor.mediumGrey))
                      ]),
                      Flexible(
                          child: Column(children: <Widget>[
                        Row(children: <Widget>[
                          Spacer(),
                          isToday(cache[index].UM!.lastMessage.toDate())
                              ? Text(DateFormat.jm().format(cache[index].UM!.lastMessage.toDate()),
                                  style: ThemeText.inter(color: ThemeColor.mediumGrey, fontSize: 14))
                              : Text(DateFormat.yMd().format(cache[index].UM!.lastMessage.toDate()),
                                  style: ThemeText.inter(color: ThemeColor.mediumGrey, fontSize: 14))
                        ])
                      ]))
                    ])),
                (cache[index].UM!.lastViewed == null ||
                        cache[index].UM!.lastViewed!.compareTo(cache[index].UM!.lastMessage) < 0)
                    ? Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.only(left: 6),
                        decoration: new BoxDecoration(
                          color: ThemeColor.secondaryBlue,
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
