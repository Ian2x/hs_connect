import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/groupView/groupTitleCard.dart';
import 'package:hs_connect/screens/home/postView/postCard.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/shared/constants.dart';
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

  String groupName= "";
  String? groupImage;
  int groupMemberCount=0;
  String groupDescription="";
  String? groupColor;

  void getGroupData() async {
    GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
    final Group? fetchGroupData = await _groups.groupFromRef(widget.groupRef);
    if (mounted) {
      setState(() {
        if (fetchGroupData!= null){
          groupName=fetchGroupData.name;
          groupDescription= fetchGroupData.description!;
          groupImage=fetchGroupData.image;
          groupMemberCount= fetchGroupData.numMembers;
          groupColor = fetchGroupData.hexColor;
        } else {groupImage = '<Failed to retrieve group name>';}
      });
    }
  }

  @override
  void initState() {
    getGroupData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);

    if (userData == null) return Loading();

    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: userData.userRef, groupRefs: [widget.groupRef]);

    return Scaffold(
      backgroundColor: ThemeColor.backgroundGrey,
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

            return ListView.builder(
                itemCount: posts.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  // when scroll up/down, fires once
                  if (index == 0){
                    return groupTitleCard(
                      name:groupName, memberCount: groupMemberCount,
                      description: groupDescription, image: groupImage,
                      hexColor: groupColor,
                    );
                  }
                  return Center(
                      child: PostCard(
                        post: posts[index],
                        currUserRef: widget.currUserRef,
                      ));
                });
            return PostsListView(posts: posts, currUserRef: userData.userRef);
          }
        },
      ),
    );
  }
}
