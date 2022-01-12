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
import 'package:hs_connect/shared/widgets/myCircle.dart';
import 'package:provider/provider.dart';
import 'package:hs_connect/models/comment.dart';

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
          if (postsAndCommentsSnapshot.hasData && postsAndCommentsSnapshot.data!=null) {
            final postsData = postsAndCommentsSnapshot.data![0];
            final commentsData = postsAndCommentsSnapshot.data![1];
            if (postsData!=null && commentsData!=null) {
              final posts = postsData as List<Post>;
              final comments = commentsData as List<Comment>;
              return FutureBuilder(
                future: Future.wait([_posts.getPosts(comments.map((comment) => comment.postRef).toList()), _groups.getGroups(
                    groupsRefs: posts.map((post) => post.groupRef).toList() +
                        comments.map((comment) => comment.groupRef).toList())]),
                builder: (BuildContext context2, AsyncSnapshot<List<dynamic>> postsForCommentsAndGroupsSnapshot) {
                  if (postsForCommentsAndGroupsSnapshot.hasData && postsForCommentsAndGroupsSnapshot.data!=null) {
                    final postsForCommentsData = postsForCommentsAndGroupsSnapshot.data![0];
                    final groupsData = postsForCommentsAndGroupsSnapshot.data![1];
                    if (postsForCommentsData!=null && groupsData!=null) {
                      final postsForComments = postsForCommentsData as List<Post?>;
                      final groups = groupsData as List<Group?>;
                      List<Widget> groupCirclesForPostsAndComments = [];
                      for (Group? group in groups) {
                        if (group == null) {
                          groupCirclesForPostsAndComments.add(Circle(
                              size: 20.0,
                              child: Loading(size: 20.0),
                              textBackgroundColor: ThemeColor.backgroundGrey));
                        } else if (group.image != null) {
                          groupCirclesForPostsAndComments.add(Circle(
                            size: 20.0,
                            child: Image.network(group.image!),
                            textBackgroundColor: ThemeColor.backgroundGrey,
                          ));
                        } else {
                          String s = group.name;
                          int sLen = s.length;
                          String initial = "?";
                          for (int j = 0; j < sLen; j++) {
                            if (RegExp(r'[a-z]').hasMatch(group.name[j].toLowerCase())) {
                              initial = group.name[j].toUpperCase();
                              break;
                            }
                          }
                          groupCirclesForPostsAndComments.add(Circle(
                              size: 20.0,
                              textBackgroundColor: translucentColorFromString(group.name),
                              child: Text(initial,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))));
                        }
                      }
                      return Container(
                          color: ThemeColor.backgroundGrey,
                          child: ListView.builder(
                            itemCount: posts.length + comments.length + 2,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.all(6.0),
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Text("Posts", style: ThemeText.titleRegular());
                              } else if (index <= posts.length) {
                                final postIndex = index - 1;
                                return PostNotificationCard(
                                    post: posts[postIndex],
                                    groupCircle: groupCirclesForPostsAndComments[postIndex]);
                              } else if (index == posts.length + 1) {
                                return Text("Comments", style: ThemeText.titleRegular());
                              } else {
                                final commentIndex = index - posts.length - 2;
                                return CommentNotificationCard(
                                    comment: comments[commentIndex],
                                    originPost: postsForComments[commentIndex],
                                    groupCircle:
                                    groupCirclesForPostsAndComments[posts.length + commentIndex]);
                              }
                            },
                          ));
                    }
                  }
                  return Loading();
                }
              );
            }
          }
          return Loading();
    }
    );




    /*return FutureBuilder(
        future: Future.wait([_posts.newActivityPosts(userData.myPostsObservedRefs), _comments.newActivityComments(userData.myCommentsObservedRefs)]),
        builder: (BuildContext context, AsyncSnapshot postsSnapshot) {
          return FutureBuilder(
              future: _comments.newActivityComments(userData.myCommentsObservedRefs),
              builder: (BuildContext context2, AsyncSnapshot commentsSnapshot) {
                if (commentsSnapshot.hasData && postsSnapshot.hasData) {
                  final comments = commentsSnapshot.data;
                  final posts = postsSnapshot.data;
                  if (comments != null && posts != null) {
                    return FutureBuilder(
                        future: _posts.getPosts(comments.map((comment) => comment.postRef).toList()),
                        builder: (BuildContext context3, AsyncSnapshot<List<Post?>> postsForCommentsSnapshot) {
                          return FutureBuilder(
                              future: _groups.getGroups(
                                  groupsRefs: posts.map((post) => post.groupRef).toList() +
                                      comments.map((comment) => comment.groupRef).toList()),
                              builder: (BuildContext context4,
                                  AsyncSnapshot<List<Group?>> groupsForPostsAndCommentsSnapshot) {
                                final postsForComments = postsForCommentsSnapshot.data;
                                final groupsForPostsAndComments = groupsForPostsAndCommentsSnapshot.data;
                                if (postsForComments != null && groupsForPostsAndComments != null) {
                                  List<Widget> groupCirclesForPostsAndComments = [];
                                  for (var group in groupsForPostsAndComments) {
                                    if (group == null) {
                                      groupCirclesForPostsAndComments.add(Circle(
                                          size: 20.0,
                                          child: Loading(size: 20.0),
                                          textBackgroundColor: ThemeColor.backgroundGrey));
                                    } else if (group.image != null) {
                                      groupCirclesForPostsAndComments.add(Circle(
                                        size: 20.0,
                                        child: Image.network(group.image!),
                                        textBackgroundColor: ThemeColor.backgroundGrey,
                                      ));
                                    } else {
                                      String s = group.name;
                                      int sLen = s.length;
                                      String initial = "?";
                                      for (int j = 0; j < sLen; j++) {
                                        if (RegExp(r'[a-z]').hasMatch(group.name[j].toLowerCase())) {
                                          initial = group.name[j].toUpperCase();
                                          break;
                                        }
                                      }
                                      groupCirclesForPostsAndComments.add(Circle(
                                          size: 20.0,
                                          textBackgroundColor: translucentColorFromString(group.name),
                                          child: Text(initial,
                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))));
                                    }
                                  }

                                  return Container(
                                      color: ThemeColor.backgroundGrey,
                                      child: ListView.builder(
                                        itemCount: posts.length + comments.length + 2,
                                        physics: BouncingScrollPhysics(),
                                        padding: EdgeInsets.all(6.0),
                                        itemBuilder: (BuildContext context, int index) {
                                          if (index == 0) {
                                            return Text("Posts", style: ThemeText.titleRegular());
                                          } else if (index <= posts.length) {
                                            final postIndex = index - 1;
                                            return PostNotificationCard(
                                                post: posts[postIndex],
                                                groupCircle: groupCirclesForPostsAndComments[postIndex]);
                                          } else if (index == posts.length + 1) {
                                            return Text("Comments", style: ThemeText.titleRegular());
                                          } else {
                                            final commentIndex = index - posts.length - 2;
                                            return CommentNotificationCard(
                                                comment: comments[commentIndex],
                                                originPost: postsForComments[commentIndex],
                                                groupCircle:
                                                    groupCirclesForPostsAndComments[posts.length + commentIndex]);
                                          }
                                        },
                                      ));
                                }
                                return Loading();
                              });
                        });
                  }
                }
                return Loading();
              };
        });*/
  }
}
