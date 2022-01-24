import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/accessRestriction.dart';
import 'package:hs_connect/models/group.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/models/userData.dart';
import 'package:hs_connect/screens/home/comments/commentsFeed.dart';
import 'package:hs_connect/services/groups_database.dart';
import 'package:hs_connect/services/posts_database.dart';
import 'package:hs_connect/services/user_data_database.dart';
import 'package:hs_connect/shared/tools/hexColor.dart';
import 'package:hs_connect/shared/widgets/loading.dart';
import 'package:hs_connect/shared/widgets/myBackButtonIcon.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  final DocumentReference postRef;
  final DocumentReference currUserRef;
  final UserData userData;

  PostPage({Key? key, required this.postRef, required this.currUserRef, required this.userData
  }) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String groupName = '';
  Post? post;

  void getData() async {
    PostsDatabaseService _posts = PostsDatabaseService(currUserRef: widget.currUserRef);


    final temp = await _posts.getPost(widget.postRef);
    if (mounted) {
      setState(() {
        post = temp;
      });
    }
    if (post != null) {
      GroupsDatabaseService _groups = GroupsDatabaseService(currUserRef: widget.currUserRef);
      final Group? fetchGroupName = await _groups.groupFromRef(post!.groupRef);
      if (fetchGroupName!=null) {
        if (fetchGroupName.accessRestriction.restrictionType==AccessRestrictionType.domain) {
          if (mounted) {
            setState(() {
              groupName = (widget.userData.fullDomainName !=null ?
                widget.userData.fullDomainName : fetchGroupName.name)!;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              groupName = fetchGroupName.name;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            groupName = '<Failed to retrieve group name>';
          });
        }
      }

    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<UserData?>(context);
    if (userData == null || post == null) {
      return Loading();
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
        leading: myBackButtonIcon(context),
      ),
      body:
          Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child:
                  CommentsFeed(post: post!, groupRef: post!.groupRef),
              ),
            ],
          )
    );
  }
}
