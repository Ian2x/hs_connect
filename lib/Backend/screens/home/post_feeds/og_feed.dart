import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/Backend/models/post.dart';
import 'package:hs_connect/Backend/services/posts_database.dart';
import 'package:hs_connect/Backend/shared/loading.dart';
import 'package:provider/provider.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {

  String groupId = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // _posts.setGroupId(groupId: 'QwUEy7kgi0J8DMCJIxvA');

    PostsDatabaseService _posts = PostsDatabaseService(groupId: groupId);

    return StreamBuilder(
      stream: _posts.singleGroupPosts,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (!snapshot.hasData) {
          return Loading();
        } else {

        final posts = (snapshot.data as List<Post?>).map((post) => post!).toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextButton.icon(
              icon: Icon(Icons.person),
              label: Text('activate'),
              onPressed: () {

                // _posts.setGroupId(groupId: 'QwUEy7kgi0J8DMCJIxvA');

                setState(() {
                  groupId = 'GEQnMIAwwbuaRZOCfb6C';
                });

              },),
            ListView.builder(
              itemCount: posts.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {// when scroll up/down, fires once
                return Center(
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text(posts[index].text),
                          subtitle: Text(posts[index].userId),
                        ),
                      ]
                    )
                  ),
                );
              },
            ),
          ],
        );
      }
      },

    );
  }
}
