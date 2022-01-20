import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/groupTag.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
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
    final group = groupFromSnapshot(groupData);
    if (group != null) {
      if (group.accessRestriction.restrictionType == AccessRestrictionType.domain) {
        final domainData = await FirebaseFirestore.instance.collection(C.domainsData).doc(group.name).get();
        if (domainData[C.fullName] != null) {
          if (mounted) {
            setState(() {
              postGroupName = domainData[C.fullName];
            });
            return;
          }
        }
      }
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

    if (userData == null ||
        profileImage == null ||
        sourceUserDisplayedName == null ||
        sourceUserFullDomainName == null ||
        postGroupName == null) {
      return Container(
          margin: EdgeInsets.only(top: 5, bottom: 5), height: 70, color: ThemeColor.white, child: Container());
    }

    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new PostPage(
                        postRef: widget.myNotification.parentPostRef,
                        currUserRef: userData.userRef,
                      )));
        },
        child: Container(
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.fromLTRB(14, 14, 14, 16),
            color: ThemeColor.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, image: DecorationImage(fit: BoxFit.fill, image: profileImage!.image))),
                SizedBox(width: 14),
                SizedBox(
                  width: 260,
                  child: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: widget.myNotification
                                .printA(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(
                                color: ThemeColor.black, fontSize: 14, fontWeight: FontWeight.bold, height: 1.35)),
                        TextSpan(
                            text: widget.myNotification
                                .printB(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(color: ThemeColor.black, fontSize: 14, height: 1.35)),
                        TextSpan(
                            text: widget.myNotification
                                .printC(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(
                                color: ThemeColor.black, fontSize: 14, fontWeight: FontWeight.bold, height: 1.35)),
                        TextSpan(
                            text: widget.myNotification
                                .printD(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(color: ThemeColor.black, fontSize: 14, height: 1.35)),
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
                            style: ThemeText.inter(color: ThemeColor.mediumGrey, fontSize: 14))
                      ],
                    )
                  ]),
                ),
              ],
            )));
  }
}

/*
Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.fromLTRB(20,20,15,12),
            color: ThemeColor.white,
            child: Column(children: <Widget>[
              Row(children: <Widget>[
                Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, image: DecorationImage(fit: BoxFit.fill, image: profileImage!.image))),
                SizedBox(width: 15),
                SizedBox(
                  width: 280,
                  child: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: widget.myNotification
                                .printA(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(
                                color: ThemeColor.black, fontSize: 14.5, fontWeight: FontWeight.bold, height: 1.5)),
                        TextSpan(
                            text: widget.myNotification
                                .printB(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(color: ThemeColor.black, fontSize: 14.5, height: 1.5)),
                        TextSpan(
                            text: widget.myNotification
                                .printC(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(
                                color: ThemeColor.black, fontSize: 14.5, fontWeight: FontWeight.bold, height: 1.5)),
                        TextSpan(
                            text: widget.myNotification
                                .printD(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(color: ThemeColor.black, fontSize: 14.5, height: 1.5)),
                      ],
                    ),
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                Text(convertTime(widget.myNotification.createdAt.toDate()),
                    style: ThemeText.inter(color: ThemeColor.mediumGrey, fontSize: 14))
              ])
            ]))
 */

/*
Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.fromLTRB(20,20,15,12),
            color: ThemeColor.white,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end,children: <Widget>[
              Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, image: DecorationImage(fit: BoxFit.fill, image: profileImage!.image))),
              SizedBox(
                width: 280,
                child: RichText(
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                          text: widget.myNotification
                              .printA(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                          style: ThemeText.inter(
                              color: ThemeColor.black, fontSize: 14.5, fontWeight: FontWeight.bold, height: 1.5)),
                      TextSpan(
                          text: widget.myNotification
                              .printB(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                          style: ThemeText.inter(color: ThemeColor.black, fontSize: 14.5, height: 1.5)),
                      TextSpan(
                          text: widget.myNotification
                              .printC(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                          style: ThemeText.inter(
                              color: ThemeColor.black, fontSize: 14.5, fontWeight: FontWeight.bold, height: 1.5)),
                      TextSpan(
                          text: widget.myNotification
                              .printD(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                          style: ThemeText.inter(color: ThemeColor.black, fontSize: 14.5, height: 1.5)),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                Text(convertTime(widget.myNotification.createdAt.toDate()),
                    style: ThemeText.inter(color: ThemeColor.mediumGrey, fontSize: 14))
              ])
            ]))
 */
