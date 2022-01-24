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
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class NotificationCard extends StatefulWidget {
  final MyNotification myNotification;
  final double wp;
  final double hp;

  const NotificationCard({Key? key, required this.myNotification, required this.wp, required this.hp}) : super(key: key);

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  Image? profileImage;
  String? sourceUserDisplayedName;
  String? sourceUserFullDomainName;
  String? postGroupName;

  UserData? userData;

  double? wp;
  double? hp;

  @override
  void initState() {
    fetchPostGroup();
    fetchSourceUser();
    if (mounted) {
      setState(() {
        wp = widget.wp;
        hp = widget.hp;
      });
    }
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

    if (wp == null || hp == null) return Loading();

    if (userData == null ||
        profileImage == null ||
        sourceUserDisplayedName == null ||
        sourceUserFullDomainName == null ||
        postGroupName == null) {
      return Container(
          margin: EdgeInsets.only(top: 2*hp!),
          padding: EdgeInsets.fromLTRB(14*wp!, 14*hp!, 14*wp!, 16*hp!),
          height: 70*hp!,
          color: ThemeColor.white);
    }

    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new PostPage(
                        userData: userData,
                        postRef: widget.myNotification.parentPostRef,
                        currUserRef: userData.userRef,
                      )));
        },
        child: Container(
            margin: EdgeInsets.only(top: 2*hp!),
            padding: EdgeInsets.fromLTRB(14*wp!, 14*hp!, 14*wp!, 16*hp!),
            color: ThemeColor.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: 40*hp!,
                    width: 40*hp!,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, image: DecorationImage(fit: BoxFit.fill, image: profileImage!.image))),
                SizedBox(width: 14*wp!),
                SizedBox(
                  width: 260*wp!,
                  child: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: widget.myNotification
                                .printA(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(
                                color: ThemeColor.black, fontSize: 14*hp!, fontWeight: FontWeight.bold, height: 1.35)),
                        TextSpan(
                            text: widget.myNotification
                                .printB(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(color: ThemeColor.black, fontSize: 14*hp!, height: 1.35)),
                        TextSpan(
                            text: widget.myNotification
                                .printC(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(
                                color: ThemeColor.black, fontSize: 14*hp!, fontWeight: FontWeight.bold, height: 1.35)),
                        TextSpan(
                            text: widget.myNotification
                                .printD(sourceUserDisplayedName!, sourceUserFullDomainName!, postGroupName!),
                            style: ThemeText.inter(color: ThemeColor.black, fontSize: 14*hp!, height: 1.35)),
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
                            style: ThemeText.inter(color: ThemeColor.mediumGrey, fontSize: 14*hp!))
                      ],
                    )
                  ]),
                ),
              ],
            )));
  }
}
