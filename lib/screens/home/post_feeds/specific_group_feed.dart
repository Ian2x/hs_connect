import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/posts_list_view.dart';
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
    if (mounted) {
      setState(() {
        groupName = fetchGroupName != null ? fetchGroupName.name : '<Failed to retrieve group name>';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    PostsDatabaseService _posts = PostsDatabaseService(groupRefs: [widget.groupRef]);

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text(groupName),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
      ),
      body: StreamBuilder(
        stream: _posts.posts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Loading();
          } else {
            final posts = (snapshot.data as List<Post?>).map((post) => post!).toList();
            return PostsListView(posts: posts, currUserRef: userData.userRef);
          }
        },
      ),
    );
  }
}
