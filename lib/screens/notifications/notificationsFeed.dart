import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
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
        future: _posts.newActivityPosts(userData.myPostsObservedRefs),
        builder: (BuildContext context, AsyncSnapshot<List<Post>> postsSnapshot) {
          return FutureBuilder(
              future: _comments.newActivityComments(userData.myCommentsObservedRefs),
              builder: (BuildContext context2, AsyncSnapshot<List<Comment>> commentsSnapshot) {
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
                                final groupsForPostsAndComments = groupsForPostsAndCommentsSnapshot.data;
                                if (groupsForPostsAndComments != null) {
                                  List<Widget> groupCirclesForPosts = [];
                                  for (var group in groupsForPostsAndComments) {
                                    if (group == null) {
                                      groupCirclesForPosts.add(Circle(
                                          child: Loading(size: 20.0), textBackgroundColor: ThemeColor.backgroundGrey));
                                    } else if (group.image != null) {
                                      groupCirclesForPosts.add(Circle(
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
                                      groupCirclesForPosts.add(Circle(
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
                                            return Text(posts[postIndex].title);
                                          } else if (index == posts.length + 1) {
                                            return Text("Comments", style: ThemeText.titleRegular());
                                          } else {
                                            final commentIndex = index - posts.length - 2;
                                            return Text(comments[commentIndex].text);
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
              });
        });
  }
}

/*
if (postsSnapshot.hasData && postsForCommentsSnapshot.hasData) {
                            final posts = postsSnapshot.data;
                            final postsForComments = postsForCommentsSnapshot.data;
                            if (posts != null && postsForComments != null) {

                              List<Widget> groupCirclesForPosts = [];
                              await Future.forEach(posts, (post) async {


                              });


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
                                        return Text(posts[postIndex].title);
                                      } else if (index == posts.length + 1) {
                                        return Text("Comments");
                                      } else {
                                        final commentIndex = index - posts.length - 2;
                                        return Text(comments[commentIndex].text);
                                      }
                                    },
                                  ));
                            }
                          }
 */
