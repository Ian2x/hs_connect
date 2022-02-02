import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/storage/image_storage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
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
  List<UMUD> UMUDcache = [];
  final ImageStorage _images = ImageStorage();

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
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    if (UMs == null || otherUsers == null) {
      return Loading();
    }

    if (otherUsers!.length == 0) {
      return Container(
          padding: EdgeInsets.only(top: 50*hp),
          alignment: Alignment.topCenter,
          child: Text("No messages :/",
              style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.normal)));
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
          final updateLastMessage = () {
            UMUDcache[index].UM!.lastMessage = Timestamp.now();
          };
          final updateLastViewed = () {
            UMUDcache[index].UM!.lastViewed = Timestamp.now();
          };
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => pixelProvider(context, child: MessagesPage(
                        currUserRef: widget.userData.userRef,
                        otherUserData: otherUser,
                        onUpdateLastMessage: updateLastMessage,
                        onUpdateLastViewed: updateLastViewed,
                      ))));
            },
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(top: index == 0 ? 4.5*hp : 2*hp, bottom: index == UMUDcache.length - 1 ? 2.5*hp : 0*hp),
                    padding: EdgeInsets.fromLTRB(20*wp, 14*hp, 14*wp, 16*hp),
                    color: colorScheme.surface,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                      Container(
                          width: 40*hp,
                          height: 40*hp,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(fit: BoxFit.fill, image: _images.profileImageProvider(otherUser.profileImageURL)))),
                      SizedBox(width: 14*wp),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Text(otherUser.fundamentalName,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4*hp),
                        Text(otherUser.fullDomainName != null ? otherUser.fullDomainName! : otherUser.domain,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: colorScheme.primary))
                      ]),
                      Flexible(
                          child: Column(children: <Widget>[
                        Row(children: <Widget>[
                          Spacer(),
                          isToday(UMUDcache[index].UM!.lastMessage.toDate())
                              ? Text(DateFormat.jm().format(UMUDcache[index].UM!.lastMessage.toDate()),
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: colorScheme.primary))
                              : Text(DateFormat.yMd().format(UMUDcache[index].UM!.lastMessage.toDate()),
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: colorScheme.primary))
                        ])
                      ]))
                    ])),
                (UMUDcache[index].UM!.lastViewed == null ||
                        UMUDcache[index].UM!.lastViewed!.compareTo(UMUDcache[index].UM!.lastMessage) < 0)
                    ? Container(
                        width: 10*wp,
                        height: 10*wp,
                        margin: EdgeInsets.only(top: index == 0 ? 4.5*hp : 2*hp, left: 6*wp, bottom: index == UMUDcache.length - 1 ? 2.5*hp : 0*hp),
                        decoration: new BoxDecoration(
                          gradient: Gradients.blueRed(),
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
