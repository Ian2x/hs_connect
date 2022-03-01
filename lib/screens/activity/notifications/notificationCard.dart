import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/myNotification.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/postLikesManager.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/postView/postPage.dart';
import 'package:hs_connect/screens/profile/profileWidgets/profileImage.dart';
import 'package:hs_connect/shared/tools/convertTime.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class NotificationCard extends StatefulWidget {
  final MyNotification myNotification;

  const NotificationCard({Key? key, required this.myNotification}) : super(key: key);

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  String? sourceUserName;
  String? postGroupName;
  Color? domainColor;
  bool loading = false;
  bool badPost = false;

  @override
  void initState() {
    if (widget.myNotification.myNotificationType != MyNotificationType.fromMe) {
      fetchPostGroup();
      fetchSourceUser();
    }
    super.initState();
  }

  void fetchPostGroup() async {
    if (widget.myNotification.myNotificationType == MyNotificationType.commentVotes ||
        widget.myNotification.myNotificationType == MyNotificationType.postVotes ||
        widget.myNotification.myNotificationType == MyNotificationType.replyVotes) {
      final postData = await widget.myNotification.parentPostRef.get();
      try {
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
      } catch (error) {
        if (mounted) {
          setState(() {
            badPost = true;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          postGroupName = "";
        });
      }
    }
  }

  void fetchSourceUser() async {
    final sourceUserData = await widget.myNotification.sourceUserRef.get();
    final sourceUser = await userDataFromSnapshot(sourceUserData, widget.myNotification.sourceUserRef);
    if (mounted) {
      setState(() {
        sourceUserName = sourceUser.fundamentalName;
        domainColor = sourceUser.domainColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (badPost) {
      return Container();
    }

    if (widget.myNotification.myNotificationType == MyNotificationType.fromMe) {
      return Container(
          margin: EdgeInsets.only(top: 2.5),
          padding: EdgeInsets.fromLTRB(14, 13, 14, 15),
          color: colorScheme.surface,
          child: Row(
            children: [
              SizedBox(
                  width: 307,
                  child: RichText(
                      maxLines: 100,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(children: [
                        TextSpan(
                            text: "Convo team: ", style: textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w600)),
                        TextSpan(text: widget.myNotification.extraData!, style: textTheme.bodyText2),
                      ]))),
              Flexible(
                child: Row(
                  children: [
                    Spacer(),
                    Text(convertTime(widget.myNotification.createdAt.toDate()),
                        style: textTheme.subtitle2?.copyWith(color: colorScheme.primary))
                  ],
                ),
              ),
            ],
          ));
    }

    if (userData == null || sourceUserName == null || postGroupName == null) {
      return Container(
          margin: EdgeInsets.only(top: 2.5),
          padding: EdgeInsets.fromLTRB(14, 13, 14, 15),
          height: 60,
          color: colorScheme.surface,
          child: loading ? Loading(backgroundColor: Colors.transparent) : null);
    }

    return GestureDetector(
        onTap: () async {
          if (mounted) {
            setState(() {
              loading = true;
            });
          }
          final post = postFromSnapshot(await widget.myNotification.parentPostRef.get());
          final group = await groupFromSnapshot(await post.groupRef.get());
          if (group != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PostPage(
                        post: post,
                        group: group,
                        postLikesManager: PostLikesManager(
                          likeStatus: post.likes.contains(userData.userRef),
                          dislikeStatus: post.dislikes.contains(userData.userRef),
                          likeCount: post.likes.length,
                          dislikeCount: post.dislikes.length,
                          onLike: () {},
                          onUnLike: () {},
                          onDislike: () {},
                          onUnDislike: () {},
                        ))));
          } else {
            log('Error fetching group');
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        },
        child: Container(
            margin: EdgeInsets.only(top: 2.5),
            padding: EdgeInsets.fromLTRB(14, 13, 14, 15),
            color: colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ProfileImage(
                      backgroundColor: domainColor,
                      size: 33,
                    ),
                    SizedBox(width: 14),
                    SizedBox(
                      width: 260,
                      child: RichText(
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: widget.myNotification.printA(sourceUserName!, postGroupName!),
                                style: textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: widget.myNotification.printB(sourceUserName!, postGroupName!),
                                style: textTheme.bodyText2),
                            TextSpan(
                                text: widget.myNotification.printC(sourceUserName!, postGroupName!),
                                style: textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: widget.myNotification.printD(sourceUserName!, postGroupName!),
                                style: textTheme.bodyText2),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Row(
                        children: [
                          Spacer(),
                          Text(convertTime(widget.myNotification.createdAt.toDate()),
                              style: textTheme.subtitle2?.copyWith(color: colorScheme.primary))
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }
}
