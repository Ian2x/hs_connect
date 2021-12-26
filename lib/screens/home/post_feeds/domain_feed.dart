import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/post_view/post_card.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

class DomainFeed extends StatefulWidget {
  const DomainFeed({Key? key}) : super(key: key);

  @override
  _DomainFeedState createState() => _DomainFeedState();
}

class _DomainFeedState extends State<DomainFeed> {
  String groupId = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    // _posts.setGroupId(groupId: 'QwUEy7kgi0J8DMCJIxvA');

    PostsDatabaseService _posts = PostsDatabaseService(groupRef: userData.userGroups[0].groupRef);

    return StreamBuilder(
      stream: _posts.singleGroupPosts,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (!snapshot.hasData) {
          return Loading();
        } else {
          final posts = (snapshot.data as List<Post?>).map((post) => post!).toList();
          // print(posts.map((post) => post!.image));

          return ListView.builder(
            itemCount: posts.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              // when scroll up/down, fires once
              return Center(
                  child: PostCard(
                postRef: posts[index].postRef,
                userRef: posts[index].userRef,
                groupRef: posts[index].groupRef,
                title: posts[index].title,
                text: posts[index].text,
                media: posts[index].media,
                createdAt: posts[index].createdAt,
                likes: posts[index].likes,
                dislikes: posts[index].dislikes,
                currUserRef: userData.userRef,
                numComments: posts[index].numComments,
              ));
            },
          );
        }
      },
    );
  }
}
