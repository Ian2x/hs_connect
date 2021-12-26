import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/post_view/post_card.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/loading.dart';
import 'package:provider/provider.dart';

class SpecificGroupFeed extends StatefulWidget {

  final DocumentReference groupRef;

  const SpecificGroupFeed({Key? key, required this.groupRef}) : super(key: key);

  @override
  _SpecificGroupFeedState createState() => _SpecificGroupFeedState();
}

class _SpecificGroupFeedState extends State<SpecificGroupFeed> {

  GroupsDatabaseService _groups = GroupsDatabaseService();

  String groupName = '<Loading group name...>';

  @override
  void initState() {
    getGroupName();
    super.initState();
  }

  void getGroupName() async {
    final Group? fetchGroupName = await _groups.getGroupData(groupRef: widget.groupRef);
    setState(() {
      groupName = fetchGroupName != null ? fetchGroupName.name : '<Failed to retrieve group name>';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    PostsDatabaseService _posts = PostsDatabaseService(groupRef: widget.groupRef);

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text(groupName),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
      ),
      body: StreamBuilder(
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
      ),
    );
  }
}
