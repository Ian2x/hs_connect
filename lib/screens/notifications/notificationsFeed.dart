import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/notifications/commentNotificationCard.dart';
import 'package:hs_connect/screens/notifications/postNotificationCard.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';
import 'package:hs_connect/shared/tools/helperFunctions.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/models/comment.dart';

const circleSize = 35.0;

class NotificationsFeed extends StatefulWidget {
  const NotificationsFeed({Key? key}) : super(key: key);

  @override
  _NotificationsFeedState createState() => _NotificationsFeedState();
}

class _NotificationsFeedState extends State<NotificationsFeed> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) {
      return Loading();
    }
    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: userData.userRef);
    CommentsDatabaseService _comments = CommentsDatabaseService(currUserRef: userData.userRef);
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: userData.userRef);

    return FutureBuilder(
        future: Future.wait([
          _posts.newActivityPosts(userData.myPostsObservedRefs),
          _comments.newActivityComments(userData.myCommentsObservedRefs)
        ]),
        builder: (BuildContext context1, AsyncSnapshot<List<dynamic>> postsAndCommentsSnapshot) {
          if (postsAndCommentsSnapshot.hasData && postsAndCommentsSnapshot.data != null) {
            final postsData = postsAndCommentsSnapshot.data![0];
            final commentsData = postsAndCommentsSnapshot.data![1];
            if (postsData != null && commentsData != null) {
              final posts = postsData as List<Post>;
              final comments = commentsData as List<Comment>;
              return FutureBuilder(
                  future: Future.wait([
                    _posts.getPosts(comments.map((comment) => comment.postRef).toList()),
                    _groups.getGroups(
                        groupsRefs: posts.map((post) => post.groupRef).toList() +
                            comments.map((comment) => comment.groupRef).toList())
                  ]),
                  builder: (BuildContext context2, AsyncSnapshot<List<dynamic>> postsForCommentsAndGroupsSnapshot) {
                    if (postsForCommentsAndGroupsSnapshot.hasData && postsForCommentsAndGroupsSnapshot.data != null) {
                      final postsForCommentsData = postsForCommentsAndGroupsSnapshot.data![0];
                      final groupsData = postsForCommentsAndGroupsSnapshot.data![1];
                      if (postsForCommentsData != null && groupsData != null) {
                        final postsForComments = postsForCommentsData as List<Post?>;
                        final groups = groupsData as List<Group?>;
                        List<Widget> groupCirclesForPostsAndComments = [];
                        for (Group? group in groups) {
                          /*if (group == null) {
                            groupCirclesForPostsAndComments.add(Circle(
                                size: circleSize,
                                child: Loading(size: 20.0),
                                textBackgroundColor: ThemeColor.backgroundGrey));
                          }*/
                        }
                        return ListView.builder(
                              itemCount: posts.length + comments.length + 2,
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.all(4.0),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  if (posts.length == 0) {
                                    return Container(
                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 2),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text("Posts",
                                            style: TextStyle(
                                                fontFamily: "Inter",
                                                color: ThemeColor.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20)),
                                        SizedBox(height: 5),
                                        Text("No new activity on your posts", style: ThemeText.regularSmall(color: ThemeColor.black))
                                      ]),
                                    );
                                  }
                                  return Container(
                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 2),
                                      child: Text("Posts",
                                          style: TextStyle(
                                              fontFamily: "Inter",
                                              color: ThemeColor.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20)));
                                } else if (index <= posts.length) {
                                  final postIndex = index - 1;
                                  Group? group = groups[postIndex];
                                  Image? groupImage = group!=null ? group.image!=null ? Image.network(group.image!): null : null;
                                  String groupName = group!=null ? group.name : '<Failed to fetch group name>';
                                  String? groupColor = group!=null ? group.hexColor : null;
                                  return PostNotificationCard(
                                    post: posts[postIndex],
                                    currUserRef: userData.userRef,
                                    groupImage: groupImage,
                                    groupName: groupName,
                                    groupColor: groupColor,
                                  );
                                } else if (index == posts.length + 1) {
                                  if (comments.length == 0) {
                                    return Container(
                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 2),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Divider(thickness: 1.3),
                                        Text("Comments", style: TextStyle(
                                            fontFamily: "Inter",
                                            color: ThemeColor.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20)),
                                        SizedBox(height: 5),
                                        Text("No new activity on your comments", style: ThemeText.regularSmall(color: ThemeColor.black))
                                      ]),
                                    );
                                  }
                                  return Container(
                                    padding: EdgeInsets.fromLTRB(5, 5, 5, 2),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Divider(thickness: 1.3),
                                      Text("Comments", style: TextStyle(
                                          fontFamily: "Inter",
                                          color: ThemeColor.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20)),
                                    ]),
                                  );
                                } else {
                                  final commentIndex = index - posts.length - 2;
                                  Group? group = groups[posts.length+commentIndex];
                                  Image? groupImage = group!=null ? group.image!=null ? Image.network(group.image!): null : null;
                                  String groupName = group!=null ? group.name : '<Failed to fetch group name>';
                                  String? groupColor = group!=null ? group.hexColor : null;
                                  return CommentNotificationCard(
                                    comment: comments[commentIndex],
                                    originPost: postsForComments[commentIndex],
                                    currUserRef: userData.userRef,
                                    groupImage: groupImage,
                                    groupName: groupName,
                                    groupColor: groupColor,
                                  );
                                }
                              },
                            );

                      }
                    }
                    return Loading();
                  });
            }
          }
          return Loading();
        });
  }
}
