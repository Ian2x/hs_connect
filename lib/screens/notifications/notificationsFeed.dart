import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/comments_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
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

    return FutureBuilder(
        future: _posts.newActivityPosts(userData.myPostsObservedRefs),
        builder: (BuildContext context, AsyncSnapshot<List<Post>> postsSnapshot) {
          return FutureBuilder(
            future: _comments.newActivityComments(userData.myCommentsObservedRefs),
            builder: (BuildContext context, AsyncSnapshot<List<Comment>> commentsSnapshot) {
              if (postsSnapshot.hasData && commentsSnapshot.hasData) {
                final posts = postsSnapshot.data;
                final comments = commentsSnapshot.data;
                return Container(
                  /*child: ListView.builder(

                  )*/
                );
              }
              return Loading();
            }
          );
        });
  }
}
