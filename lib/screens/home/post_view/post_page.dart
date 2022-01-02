import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/user_data.dart';
import 'package:hs_connect/screens/home/comment_feed/comments_feed.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/tools/hexcolor.dart';
import 'package:hs_connect/screens/home/post_view/Widgets/RoundedPostCard.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  final Post postInfo;

  PostPage({Key? key, required this.postInfo}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  GroupsDatabaseService _groups = GroupsDatabaseService();

  String groupName = 'Loading Group name...';

  void getGroupName() async {
    final Group? fetchGroupName = await _groups.getGroupData(groupRef: widget.postInfo.groupRef);
    if (mounted) {
      setState(() {
        groupName = fetchGroupName != null ? fetchGroupName.name : '<Failed to retrieve group name>';
      });
    }
  }

  @override
  void initState() {
    getGroupName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData?>(context);
    if (userData == null) {
      return Text("loading");
    }

    return Scaffold(
      backgroundColor: HexColor("FFFFFF"),
      appBar: AppBar(
        title: Text(groupName,
            style: TextStyle(
              color: HexColor('222426'), //fontFamily)
            )),
        backgroundColor: HexColor("FFFFFF"),
        elevation: 0.0,
      ),
      body:  CommentsFeed(postInfo: widget.postInfo),
    );
  }
}
