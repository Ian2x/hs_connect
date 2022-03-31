import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/inputDecorations.dart';
import 'MessagesPage.dart';

class UMUD {
  UserMessage? UM;
  OtherUserData? UD;

  UMUD({required this.UM, required this.UD});
}

class AllMessagesPage extends StatefulWidget {
  final UserData currUserData;

  const AllMessagesPage({Key? key, required this.currUserData}) : super(key: key);

  @override
  _AllMessagesPageState createState() => _AllMessagesPageState();
}

class _AllMessagesPageState extends State<AllMessagesPage> {
  List<UMUD> UMUDcache = [];
  bool loading = false;

  @override
  void initState() {
    fetchUsers(widget.currUserData);
    super.initState();
  }

  Future _fetchUsersHelper(DocumentReference otherUserRef, int index, List<OtherUserData?> results) async {
    try {
      results[index] = await otherUserDataFromSnapshot(await otherUserRef.get(), otherUserRef);
    } catch (e) {
      results[index] = null;
    }
  }

  Future fetchUsers(UserData? userData) async {
    if (userData == null) {
      return;
    }
    if (mounted) {
      setState(() => loading = true);
    }
    List<UserMessage> tempUMs = userData.userMessages;
    List<UMUD> tempUMUDcache = [];
    for (UserMessage UM in tempUMs) {
      tempUMUDcache.add(UMUD(UM: UM, UD: null));
    }
    List<OtherUserData?> tempOtherUsers = List.filled(tempUMs.length, null);
    await Future.wait(
        [for (int i = 0; i < tempUMs.length; i++) _fetchUsersHelper(tempUMs[i].otherUserRef, i, tempOtherUsers)]);
    List<OtherUserData?> tempTempOtherUsers = [];
    for (int i = 0; i < tempOtherUsers.length; i++) {
      tempTempOtherUsers.add(tempOtherUsers[i]);
    }
    if (tempTempOtherUsers.length == tempUMs.length) {
      for (int i = 0; i < tempTempOtherUsers.length; i++) {
        tempUMUDcache[i].UD = tempTempOtherUsers[i];
      }
    }
    if (mounted) {
      setState(() {
        UMUDcache = tempUMUDcache;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (loading) {
      return Loading();
    }

    if (UMUDcache.length == 0) {
      return Container(
          padding: EdgeInsets.only(top: 50),
          alignment: Alignment.topCenter,
          child: Text("No chats :/", style: textTheme.headline6));
    }

    // sorted by latest first
    UMUDcache.sort((UMUD a, UMUD b) {
      if (a.UM == null) {
        if (b.UM == null) {
          return 0;
        }
        return 1;
      } else if (b.UM == null) {
        return -1;
      }
      return b.UM!.lastMessage.compareTo(a.UM!.lastMessage);
    });

    return RefreshIndicator(
      onRefresh: () {
        final tempUserData = Provider.of<UserData?>(context, listen: false);
        return fetchUsers(tempUserData);
      },
      child: ListView.builder(
          itemCount: UMUDcache.length,
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            if (UMUDcache[index].UD==null || UMUDcache[index].UM == null) {
              return Container();
            }
            final otherUser = UMUDcache[index].UD!;
            if (widget.currUserData.blockedUserRefs.contains(otherUser.userRef)) {
              return Container();
            }
            final updateLastMessage = () {
              UMUDcache[index].UM!.lastMessage = Timestamp.now();
            };
            final updateLastViewed = () {
              UMUDcache[index].UM!.lastViewed = Timestamp.now();
            };
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                final _ = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessagesPage(
                              currUserRef: widget.currUserData.userRef,
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
                  Column(
                    children: [
                      index == 0 ? Divider(height: 0.5) : Container(),
                      Container(
                          // margin: EdgeInsets.only(top: index == 0 ? 4.5 : 2, bottom: index == UMUDcache.length - 1 ? 2.5 : 0),
                          padding: EdgeInsets.fromLTRB(20, 13, 14, 15),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                            ProfileImage(backgroundColor: otherUser.domainColor, size: 33),
                            SizedBox(width: 14),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                              Text(otherUser.fundamentalName, style: textTheme.bodyText2),
                              SizedBox(height: 4),
                              Text(otherUser.fullDomainName ?? otherUser.domain,
                                  style: textTheme.bodyText2?.copyWith(color: otherUser.domainColor ?? colorScheme.primary))
                            ]),
                            Flexible(
                                child: Column(children: <Widget>[
                              Row(children: <Widget>[
                                Spacer(),
                                isToday(UMUDcache[index].UM!.lastMessage.toDate())
                                    ? Text(DateFormat.jm().format(UMUDcache[index].UM!.lastMessage.toDate()),
                                        style: textTheme.subtitle2?.copyWith(color: colorScheme.primary))
                                    : Text(DateFormat.yMd().format(UMUDcache[index].UM!.lastMessage.toDate()),
                                        style: textTheme.subtitle2?.copyWith(color: colorScheme.primary))
                              ])
                            ]))
                          ])),
                      Divider(height: 0.5)
                    ],
                  ),
                  (UMUDcache[index].UM!.lastViewed == null ||
                          UMUDcache[index].UM!.lastViewed!.compareTo(UMUDcache[index].UM!.lastMessage) < 0)
                      ? Container(
                          width: 10,
                          height: 10,
                          margin: EdgeInsets.only(
                              top: index == 0 ? 4.5 : 2, left: 6, bottom: index == UMUDcache.length - 1 ? 2.5 : 0),
                          decoration: BoxDecoration(
                            color: (UMUDcache[index].UM!.lastViewed == null ||
                                    UMUDcache[index].UM!.lastViewed!.compareTo(UMUDcache[index].UM!.lastMessage) < 0)
                                ? colorScheme.secondary
                                : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        )
                      : Container()
                ],
              ),
            );
          }),
    );
  }
}
