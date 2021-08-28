import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:provider/provider.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {

  String groupId = '';

  PostsDatabaseService _posts = PostsDatabaseService(groupId: 'QwUEy7kgi0J8DMCJIxvA');

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // _posts.setGroupId(groupId: 'QwUEy7kgi0J8DMCJIxvA');

    print("BELOW IS FEED");
    return StreamBuilder(
      stream: _posts.groupPosts,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (!snapshot.hasData) {
          print('no data :/');
          return Loading();
        } else {

        final posts = (snapshot.data as List<Post?>).map((post) => post!).toList();
        // print(posts.map((post) => post!.image));

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (BuildContext context, int index) {// when scroll up/down, fires once
            return Center(
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(posts[index].text),
                      subtitle: Text(posts[index].userId),
                    )
                  ]
                )
              ),
            );
          },
        );
      }
      },

    );
  }
}
