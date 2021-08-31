import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/post_view/post_card.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:provider/provider.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({Key? key}) : super(key: key);

  @override
  _HomeFeedState createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  List<String> groupsId = [];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    PostsDatabaseService _posts = PostsDatabaseService(groupsId: userData.userGroups.map((userGroup) => userGroup.groupId).toList());

    return StreamBuilder(
      stream: _posts.multiGroupPosts,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (!snapshot.hasData) {
          print('no data :/');
          return Loading();
        } else {
          final posts = (snapshot.data as List<Post?>).map((post) => post!).toList();

          return ListView.builder(
            itemCount: posts.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              // when scroll up/down, fires once
              return Center(
                child: PostCard(
                  postId: posts[index].postId,
                  userId: posts[index].userId,
                  groupId: posts[index].groupId,
                  title: posts[index].title,
                  text: posts[index].text,
                  image: posts[index].image,
                  createdAt: posts[index].createdAt,
                  likes: posts[index].likes,
                  dislikes: posts[index].dislikes,
                  currUserId: user.uid,
                )
              );
            },
          );
        }
      },
    );
  }
}
