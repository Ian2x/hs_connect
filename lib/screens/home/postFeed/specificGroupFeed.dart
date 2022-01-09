import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/postsListView.dart';
import 'package:provider/provider.dart';

class SpecificGroupFeed extends StatefulWidget {
  final DocumentReference groupRef;
  final DocumentReference currUserRef;

  const SpecificGroupFeed({Key? key, required this.groupRef, required this.currUserRef}) : super(key: key);

  @override
  _SpecificGroupFeedState createState() => _SpecificGroupFeedState();
}

class _SpecificGroupFeedState extends State<SpecificGroupFeed> {

  String groupName = '<Loading group name...>';

  @override
  void initState() {
    getGroupName();
    super.initState();
  }

  void getGroupName() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroupName = await _groups.groupFromRef(widget.groupRef);
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

    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: userData.userRef, groupRefs: [widget.groupRef]);

    return Scaffold(
      backgroundColor: HexColor("#E9EDF0"),
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
            List<Post?> postss = (snapshot.data as List<Post?>);
            postss.removeWhere((value) => value == null);
            List<Post> posts = postss.map((item) => item!).toList();

            return PostsListView(posts: posts, currUserRef: userData.userRef);
          }
        },
      ),
    );
  }
}
