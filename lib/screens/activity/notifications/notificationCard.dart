import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/pageRoutes.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:provider/provider.dart';

class NotificationCard extends StatefulWidget {
  final MyNotification myNotification;

  const NotificationCard({Key? key, required this.myNotification}) : super(key: key);

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  Image? profileImage;
  String? sourceUserDisplayedName;
  String? sourceUserFullDomainName;
  String? postGroupName;

  UserData? userData;

  @override
  void initState() {
    fetchPostGroup();
    fetchSourceUser();
    super.initState();
  }


  void fetchPostGroup() async {
    final postData = await widget.myNotification.parentPostRef.get();
    final post = postFromSnapshot(postData);
    final groupData = await post.groupRef.get();
    final group = await groupFromSnapshot(groupData);
    if (group != null) {
      if (mounted) {
        setState(() {
          postGroupName = group.name;
        });
      }
    }
  }

  void fetchSourceUser() async {
    final sourceUserData = await widget.myNotification.sourceUserRef.get();
    final sourceUser = await userDataFromSnapshot(sourceUserData, widget.myNotification.sourceUserRef);
    if (mounted) {
      setState(() {
        profileImage = sourceUser.profileImage;
        sourceUserDisplayedName = sourceUser.displayedName;
        sourceUserFullDomainName = sourceUser.fullDomainName != null ? sourceUser.fullDomainName : sourceUser.domain;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final wp = Provider.of<WidthPixel>(context).value;
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    if (userData == null ||
        profileImage == null ||
        sourceUserDisplayedName == null ||
        sourceUserFullDomainName == null ||
        postGroupName == null) {
      return Container(
          margin: EdgeInsets.only(top: 2*hp),
          padding: EdgeInsets.fromLTRB(14*wp, 14*hp, 14*wp, 16*hp),
          height: 70*hp,
          color: colorScheme.surface);
    }

    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => pixelProvider(context, child: PostPage(
                    userData: userData,
                    postRef: widget.myNotification.parentPostRef,
                    currUserRef: userData.userRef,
                  ))));
        },
        child: Container(
            margin: EdgeInsets.only(top: 2*hp),
            padding: EdgeInsets.fromLTRB(14*wp, 14*hp, 14*wp, 16*hp),
            color: colorScheme.surface,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: 40*hp,
                    width: 40*hp,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, image: DecorationImage(fit: BoxFit.fill, image: profileImage!.image))),
                SizedBox(width: 14*wp),
                SizedBox(
                  width: 260*wp,
                  child: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: widget.myNotification
                                .printA(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: widget.myNotification
                                .printB(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: Theme.of(context).textTheme.subtitle2),
                        TextSpan(
                            text: widget.myNotification
                                .printC(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: widget.myNotification
                                .printD(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: Theme.of(context).textTheme.subtitle2),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Column(children: <Widget>[
                    Row(
                      children: [
                        Spacer(),
                        Text(convertTime(widget.myNotification.createdAt.toDate()),
                            style: Theme.of(context).textTheme.subtitle2?.copyWith(color: colorScheme.primary))
                      ],
                    )
                  ]),
                ),
              ],
            )));
  }
}
